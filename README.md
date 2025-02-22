# Report warnings

[![CI badge][1]][2]

This GitHub action parses C++ build logs to count warnings and creates a Markdown report
from that. If warnings are found an annotation can be shown in the log. Additionally, the
report can be added to the [job
summary](https://github.blog/news-insights/product-news/supercharging-github-actions-with-job-summaries/)
shown as a [sticky PR
comment](https://github.com/marketplace/actions/sticky-pull-request-comment) and/or be
uploaded as an artifact. See [action.yml](action.yml) for inputs and other details.


## Example usage

To capture the output of your build tool and store it in a file while still printing it to
the console, you can use `tee` (for Unix-like systems) or `Tee-Object` (for PowerShell).
This ensures that the output is visible in the GitHub Action's log. The filenames of the
logs must follow the format: `<compiler>_<config>_build.log`. See the description of the `build-logs` input in [action.yml](action.yml) for more details.

~~~yml
- name: Build debug and release configuration
  run: |
    # In bash
    cmake --build --preset ci-debug | tee GCC_Debug_build.log
    cmake --build --preset ci-release | tee GCC_Release_build.log
    # In PowerShell
    cmake --build --preset ci-debug | Tee-Object -FilePath MSVC_Debug_build.log
    cmake --build --preset ci-release | Tee-Object -FilePath MSVC_Release_build.log

- name: Count warnings and report the results
  uses: fantana21/report-warnings@v1
  with:
    - build-logs: |
        GCC_Debug_build.log
        GCC_Release_build.log
        MSVC_Debug_build.log
        MSVC_Release_build.log
~~~


## Example output

The generated warnings report might look something like this:

**Ubuntu**:

---
## Warnings report

| Compiler | Configuration | # Warnings |
|:---------|:--------------|-----------:|
| GCC | Debug | 3 + 5 |
| GCC | Release | 3 + 5 |
| Clang | Debug | 4 + 3 |
| Clang | Release | 4 + 3 |
---

**Windows**:

---
## Warnings report

| Compiler | Configuration | # Warnings |
|:---------|:--------------|-----------:|
| clang-cl | Debug | 2 + 0 |
| clang-cl | Release | 2 + 0 |
| MSVC | Debug | 2 + 2 |
| MSVC | Release | 2 + 2 |
---

The number of warnings is split into compiler warnings and clang-tidy warnings. For
example, in the first report, there are 3 warnings from the GCC compiler and 5 clang-tidy
warnings, or 4 warnings from Clang and 3 clang-tidy warnings.


## License

[MIT License](LICENSE)


[1]: https://github.com/fantana21/report-warnings/actions/workflows/ci.yml/badge.svg
[2]: https://github.com/fantana21/report-warnings/actions/workflows/ci.yml
