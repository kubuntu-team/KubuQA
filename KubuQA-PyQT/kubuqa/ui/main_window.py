"""Primary application window skeleton."""

from __future__ import annotations

from PyQt6.QtWidgets import QLabel, QMainWindow


class MainWindow(QMainWindow):
    """Placeholder main window until full UI is implemented."""

    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("KubuQA PyQt")
        self.setMinimumSize(800, 600)

        placeholder = QLabel(
            "Welcome to KubuQA PyQt.\n"
            "UI components will be added as development progresses."
        )
        placeholder.setMargin(24)
        self.setCentralWidget(placeholder)
