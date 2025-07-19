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
- **Seasonal patterns**: 12-hour cycles (144 data points) common in meteorological data
- **Missing data**: Common in outdoor wind measurements, requires sophisticated imputation