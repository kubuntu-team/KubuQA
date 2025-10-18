"""Minimal application entry point for the KubuQA PyQt project."""

from __future__ import annotations

import sys

from PyQt6.QtWidgets import QApplication, QLabel, QMainWindow


class MainWindow(QMainWindow):
    """Temporary main window showing placeholder content until full UI arrives."""

    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("KubuQA PyQt")
        self.setMinimumSize(800, 600)

        placeholder = QLabel(
            "KubuQA PyQt is under active development.\n"
            "Use this window as a smoke test for the project bootstrap."
        )
        placeholder.setMargin(24)
        placeholder.setAlignment(
            placeholder.alignment()
        )  # Keep default alignment while enabling margin.

        self.setCentralWidget(placeholder)


def main() -> None:
    """Create the Qt application and display the main window."""
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
