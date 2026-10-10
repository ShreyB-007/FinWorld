# FinWorld

A configurable financial-world simulation engine.

## Setup

**Prerequisites:** Git and Python 3.14.x.

```powershell
git clone <repository-url>
cd FinWorld
py -3.14 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
```

## Verify Setup

```powershell
python -m pytest
python -m ruff check .
```

## Contributing

Create a feature branch, commit and push your changes, then open a pull request to `master`.

**Note:** Do not commit `.venv/`.