SHELL := /bin/bash
PYTHON ?= python3
VENV_DIR := .venv
PIP := $(VENV_DIR)/bin/pip
PYTHON_BIN := $(VENV_DIR)/bin/python

.PHONY: install clean build package run test

install: $(PYTHON_BIN)
	@$(PIP) install --upgrade pip --no-cache-dir
	@if [ -f requirements.txt ]; then \
		$(PIP) install --no-cache-dir -r requirements.txt; \
	fi

$(PYTHON_BIN):
	@$(PYTHON) -m venv $(VENV_DIR)

clean:
	@rm -rf $(VENV_DIR) build dist
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	@rm -rf .pytest_cache .mypy_cache

build: install
	@if [ -f pyproject.toml ]; then \
		$(PIP) install --no-cache-dir build; \
		$(PYTHON_BIN) -m build; \
	else \
		echo "No pyproject.toml found; skipping build step."; \
	fi

package: install
	@if [ -f pyinstaller.spec ]; then \
		if [ ! -x $(VENV_DIR)/bin/pyinstaller ]; then \
			$(PIP) install --no-cache-dir pyinstaller; \
		fi; \
		$(VENV_DIR)/bin/pyinstaller pyinstaller.spec; \
	else \
		echo "PyInstaller spec not found. Create pyinstaller.spec to enable packaging."; \
	fi

run: install
	@if [ -f app.py ]; then \
		$(PYTHON_BIN) app.py; \
	else \
		echo "Entry point app.py not found. Please create it before running."; \
	fi

test: install
	@if [ ! -x $(VENV_DIR)/bin/pytest ]; then \
		$(PIP) install --no-cache-dir pytest; \
	fi
	@$(VENV_DIR)/bin/pytest -q
