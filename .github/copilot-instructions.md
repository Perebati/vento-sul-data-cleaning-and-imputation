# Wind Data Analysis - AI Assistant Instructions

Don't use emojis or markdown formatting in responses. Provide clear, concise instructions and code snippets. Keep comments on third person perspective.

## Project Overview
This is a wind data analysis project that processes SODAR (Sonic Detection and Ranging) wind measurement data from TXT files to CSV format and applies advanced statistical filtering for missing value imputation.

## Key Architecture & Data Flow

### Data Pipeline Structure
1. **Raw Data** (`raw_data/`) → TXT files with semicolon delimiters containing wind measurements
4. **Notebooks** (`notebooks/`) → Jupyter notebooks for data processing and analysis

### Critical File Types
- **Wind measurement files**: `Dir.txt`, `U.txt`, `V.txt`, `W.txt`, `WS.txt` (Direction, U/V/W components, Wind Speed)
- **Data structure**: DateTime column (`DT`) + multiple SODAR sensor heights (30m-280m in 10m increments)
- **Sampling frequency**: 10-minute intervals (144 points = 24 hours for seasonal decomposition)

## Development Workflows

### Environment Setup
```bash
# Automated environment management
./setup_env.sh  # Creates/updates .venv with all dependencies
source .venv/bin/activate  # Manual activation
```

### Key Dependencies
- **Core**: pandas, numpy for data manipulation
- **Statistical**: statsmodels (UnobservedComponents for Kalman filtering)
- **Visualization**: matplotlib, seaborn, plotly, windrose
- **Notebooks**: jupyter, jupyterlab, ipykernel

## Project-Specific Patterns

### Data Processing Conventions
- **File naming**: Preserve original names through pipeline (`Dir.txt` → `Dir.csv` → `Dir_filtered.csv`)
- **Encoding**: UTF-8 throughout the pipeline
- **Path handling**: Use `pathlib.Path` for cross-platform compatibility

### Directory Structure Pattern
- Use relative paths from project root
- Separate notebooks in `notebooks/` subdirectory  
- Automated directory creation with `mkdir(exist_ok=True)`
- Progressive data refinement through multiple directories

### Data Validation
- Check for expected SODAR column structure (DT + sensor heights)
- Validate seasonal decomposition period matches data frequency
- Verify file existence before processing

### Cross-Component Communication
- Notebooks reference relative paths (`../raw_data`, `../converted_csv_data`)
- Scripts create output directories automatically
- Consistent error handling with colored terminal output

## Key Files for Understanding Patterns
- `setup_env.sh`: Environment management and dependency handling
- `notebooks/txt_to_csv_converter.ipynb`: Data conversion workflow
- `requirements.txt`: Project-specific scientific computing stack
- `README.md`: Complete setup and usage documentation

## Wind Data Domain Knowledge
- **SODAR sensors**: Measure wind at multiple heights (30-280m)
- **Seasonal patterns**: 24-hour cycles (144 data points) common in meteorological data.
- **Missing data**: Common in outdoor wind measurements, requires sophisticated imputation

## Useful functions and Methods
- **For short gaps (≤6h)**: Interpolation + Kalman filtering
- **For long gaps (>6h)**: Base the logic following the `WindGapFiller` class implementation
    class WindGapFiller:
        """
        Classe para preenchimento inteligente de gaps em dados de vento
        """
        
        def __init__(self, data_series):
            self.data = data_series.copy()
            self.filled_data = data_series.copy()
            self.confidence_scores = pd.Series(index=data_series.index, dtype=float)
            self.fill_methods = pd.Series(index=data_series.index, dtype=str)
            
            # Inicializar confiança: 1.0 para dados originais, NaN para faltantes
            self.confidence_scores[~data_series.isna()] = 1.0
            self.fill_methods[~data_series.isna()] = 'original'
        
        
        def fill_long_gaps(self, random_state: int | None = None) -> int:

            Melhorias principais em relação à versão original:
            - Ajuste sazonal adicional por dia‑da‑semana (dow).
            - Ruído AR(1) para correlação temporal e menor volatilidade artificial.
            - Comprimento de "blending" adaptativo proporcional ao tamanho do gap.
            - Suavização opcional (Savitzky–Golay ou média móvel) para remover artefatos.
            - Perfil de confiança logístico que pondera bordas/magnitude do gap.

            O protótipo e o valor de retorno permanecem inalterados.
            """
            import numpy as np
            import pandas as pd

            rng = np.random.default_rng(random_state)

            # Seleciona apenas gaps superiores a 48 h
            gaps = [g for g in self._identify_gaps() if g["duration_hours"] > 48]
            if not gaps:
                return 0

            stats = self._calculate_seasonal_statistics()

            # ---- Fatores horários -------------------------------------------------------
            hourly_vec = np.array([stats["hourly_factors"].get(h, 1.0) for h in range(24)])
            hourly_std_vec = np.array([
                stats.get("hourly_std", {}).get(h, stats["overall_std"]) for h in range(24)
            ])

            daily_mean   = stats["daily_means"]
            overall_mean = stats["overall_mean"]
            overall_std  = stats["overall_std"]

            # ---- Fatores dia‑da‑semana (dow) -------------------------------------------
            if "dow_factors" in stats:
                dow_vec = np.array([stats["dow_factors"].get(d, 1.0) for d in range(7)])
            else:
                # Calcula em tempo de execução caso não exista
                group_mean = (
                    self.filled_data.groupby(self.filled_data.index.dayofweek)
                    .mean(numeric_only=True)
                )
                # `group_mean` pode ser Series (caso `filled_data` seja Series) ou DataFrame
                if isinstance(group_mean, pd.DataFrame):
                    # Seleciona a primeira coluna numérica disponível
                    num_cols = group_mean.select_dtypes(include=[np.number])
                    if num_cols.shape[1] > 0:
                        dow_means = num_cols.iloc[:, 0]
                    else:
                        dow_means = pd.Series(1.0, index=range(7))
                else:  # já é Series
                    dow_means = group_mean

                # Converte médias em fatores relativos
                ref = dow_means.mean() if not np.isnan(dow_means.mean()) else 1.0
                dow_vec = (dow_means / ref).fillna(1.0).to_numpy()
                if dow_vec.size != 7:
                    dow_vec = np.ones(7)

            filled_total = 0

            # ---------------------------------------------------------------------------
            for gap in gaps:
                idx = pd.date_range(gap["start"], gap["end"], freq="10min")
                idx = idx.intersection(self.filled_data.index)
                if idx.empty:
                    continue

                doy = idx.dayofyear.to_numpy()
                hr  = idx.hour.to_numpy()
                dow = idx.dayofweek.to_numpy()

                mu_day = np.array([daily_mean.get(d, overall_mean) for d in doy])
                base   = mu_day * hourly_vec[hr] * dow_vec[dow]

                sigma = np.maximum(hourly_std_vec[hr], overall_std * 0.1)

                # ---- Ruído AR(1) para suavidade temporal --------------------------------
                phi   = 0.85  # persistência
                eps   = rng.normal(0, sigma)
                noise = np.empty_like(base)
                noise[0] = eps[0]
                coef = np.sqrt(1 - phi ** 2)
                for t in range(1, len(base)):
                    noise[t] = phi * noise[t - 1] + eps[t] * coef

                values = np.clip(base + noise, a_min=0, a_max=None)

                # ---- Blending adaptativo nas bordas -------------------------------------
                max_blend = 72  # máx. 12 h (72 amostras de 10 min)
                edge_len  = int(min(max_blend, max(12, gap["duration_hours"] * 6)))
                if (
                    len(values) > 2 * edge_len
                    and (idx[0] - pd.Timedelta(minutes=10)) in self.filled_data.index
                    and (idx[-1] + pd.Timedelta(minutes=10)) in self.filled_data.index
                ):
                    w     = np.linspace(0, 1, edge_len)
                    prev  = self.filled_data.loc[idx[0] - pd.Timedelta(minutes=10)]
                    next_ = self.filled_data.loc[idx[-1] + pd.Timedelta(minutes=10)]
                    values[:edge_len]  = prev  * (1 - w)      + values[:edge_len]  * w
                    values[-edge_len:] = next_ * w[::-1]      + values[-edge_len:] * (1 - w[::-1])

                # ---- Suavização opcional -------------------------------------------------
                try:
                    from scipy.signal import savgol_filter
                    if len(values) >= 21:  # janela ímpar < len
                        values = savgol_filter(values, 21, 3, mode="interp")
                except Exception:
                    values = (
                        pd.Series(values, index=idx)
                        .rolling(window=9, center=True, min_periods=1)
                        .mean()
                        .to_numpy()
                    )

                # ---- Persiste resultados -------------------------------------------------
                self.filled_data.loc[idx] = values

                # ---- Confiança com perfil logístico --------------------------------------
                x = np.linspace(-2, 2, len(idx))
                edge_profile = 1 - 1 / (1 + np.exp(-x))  # 0 no centro, 1 nas bordas
                size_penalty = np.clip(1 - gap["duration_hours"] / (30 * 24), 0.2, 0.8)
                conf = 0.2 + 0.6 * edge_profile * size_penalty
                self.confidence_scores.loc[idx] = conf

                self.fill_methods.loc[idx] = "seasonal_blend"
                filled_total += len(idx)

            print(f"✓ {filled_total} pontos preenchidos em gaps longos")
            return filled_total


        
        def _identify_gaps(self):
            """
            Identifica gaps atuais nos dados
            """
            is_missing = self.filled_data.isna()
            missing_diff = is_missing.astype(int).diff().fillna(0)
            
            gap_starts = self.filled_data.index[missing_diff == 1].tolist()
            gap_ends = self.filled_data.index[missing_diff == -1].tolist()
            
            if is_missing.iloc[0]:
                gap_starts.insert(0, self.filled_data.index[0])
            if is_missing.iloc[-1]:
                gap_ends.append(self.filled_data.index[-1])
            
            gaps = []
            for start, end in zip(gap_starts, gap_ends):
                duration_hours = (end - start).total_seconds() / 3600
                gaps.append({
                    'start': start,
                    'end': end,
                    'duration_hours': duration_hours
                })
            
            return gaps
        
        def _calculate_hourly_patterns(self):
            """
            Calcula padrões horários dos dados válidos
            """
            valid_data = self.filled_data.dropna()
            hourly_stats = valid_data.groupby(valid_data.index.hour).agg(['mean', 'std']).fillna(valid_data.std())
            
            return {
                'mean': hourly_stats['mean'].to_dict(),
                'std': hourly_stats['std'].to_dict()
            }
        
        def _calculate_seasonal_statistics(self):
            """
            Calcula estatísticas sazonais mais detalhadas
            """
            valid_data = self.filled_data.dropna()
            
            # Padrões diários (dia do ano)
            daily_means = valid_data.groupby(valid_data.index.dayofyear).mean().to_dict()
            
            # Fatores horários normalizados
            hourly_means = valid_data.groupby(valid_data.index.hour).mean()
            overall_mean = valid_data.mean()
            hourly_factors = (hourly_means / overall_mean).to_dict()
            
            return {
                'daily_means': daily_means,
                'hourly_factors': hourly_factors,
                'overall_mean': overall_mean,
                'overall_std': valid_data.std()
            }
        
        def get_results(self):
            """
            Retorna resultados do preenchimento
            """
            return {
                'filled_data': self.filled_data,
                'confidence_scores': self.confidence_scores,
                'fill_methods': self.fill_methods
            }

    print("✓ Classe WindGapFiller implementada")