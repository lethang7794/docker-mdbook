# mdbook-pagetoc

[slowsage/mdbook-pagetoc: mdBook preprocessor to provides a table of contents for each page](https://github.com/slowsage/mdbook-pagetoc)

## Installation

- `book.toml`

  ```toml
  [preprocessor.pagetoc]
  
  [output.html]
  additional-css = ["theme/pagetoc.css"]
  additional-js  = ["theme/pagetoc.js"]
  ```

- Modify `index.hbs`

  - From:

    ```hbs
    <main>
      {{{content}}}
    </main>
    ```

  - To:

    ```hbs
    <main><div class="sidetoc"><nav class="pagetoc"></nav></div>
      {{{content}}}
    </main>
    ```

- Copy `pagetoc.css` and `pagetoc.js` to `theme` directory

## Example

This page is an example

### Section 1

### Section 2

### Section 3

### Section 4

### Section 5

### Section 6

### Section 7

### Section 8

### Section 9

### Section 10

### Section 11

### Section 12

### Section 13

### Section 14

### Section 15

### Section 16

### Section 17

### Section 18

### Section 19

### Section 20
