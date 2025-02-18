# Report warnings

[![CI badge][1]][2]

This GitHub action parses C++ build logs to count warnings and creates a Markdown report
from that. If warnings are found an annotation can be shown in the log. Additionally, the
report can be added to the [job
summary](https://github.blog/news-insights/product-news/supercharging-github-actions-with-job-summaries/)
shown as a [sticky PR
comment](https://github.com/marketplace/actions/sticky-pull-request-comment) and/or be
uploaded as an artifact. See [action.yml](action.yml) for details.


## License

[MIT License](LICENSE)


[1]: https://github.com/fantana21/report-warnings/actions/workflows/ci.yml/badge.svg
[2]: https://github.com/fantana21/report-warnings/actions/workflows/ci.yml
