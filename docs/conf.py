project = "WxBox Stack"
copyright = "2024, Mantari"
author = "Mantari"
release = "2.1"

extensions = [
    "myst_parser",
    "sphinx_copybutton",
]

source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}

exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "sphinx_rtd_theme"
html_theme_options = {
    "navigation_depth": 4,
    "collapse_navigation": False,
    "titles_only": False,
}

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "tasklist",
]
