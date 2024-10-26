---
layout: post
title: Blogging Like a Hacker
---

# mdbook-yml-header

[dvogt23/mdbook-yml-header: mdBook preprocessor to remove yml-header (front-matter) within --- at the top of a .md file](https://github.com/dvogt23/mdbook-yml-header)

## Installation

`book.toml`

```toml
[preprocessor.yml-header]
```

## Examples

- This page has a frontmatter of

  ```md
  ---
  layout: post
  title: Blogging Like a Hacker
  ---
  ```

  which isn't render by mdbook.
