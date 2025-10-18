"""Minimal application entry point for the KubuQA PyQt project."""

from __future__ import annotations

import sys

from PyQt6.QtWidgets import QApplication

from kubuqa.ui import MainWindow


def main() -> None:
    """Create the Qt application and display the main window."""
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
