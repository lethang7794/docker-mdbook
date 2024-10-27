# Dockerfile for mdBook

[![license](https://img.shields.io/github/license/lethang7794/docker-mdbook.svg)](https://github.com/lethang7794/docker-mdbook/blob/main/LICENSE)
![image tags](https://ghcr-badge.egpl.dev/lethang7794/mdbook/tags?color=%2344cc11&ignore=latest%2Clatest-rust&n=3&label=image+tags&trim=)

> [!IMPORTANT]
> This is a fork of [peaceiris/docker-mdbook] with more [pre-installed preprocessors](#pre-installed-preprocessors-for-mdbook) for mdBook

Dockerfile for [mdBook] - a utility to create modern online books from Markdown files (Like Gitbook but implemented in Rust).

## Image overview

### Image Variants

#### `mdbook:<version>` - Minimum image

- This image is based on the popular [Alpine Linux project⁠](https://alpinelinux.org/) available in [the `alpine` official image] [^1].

#### `mdbook:<version>-rust` - Including `rust`

- This image is based on the [`rust-alpine` official image](https://hub.docker.com/_/rust) (which is also based on [the `alpine` official image]).

> [!NOTE]
> If you need to run `mdbook test`, use `mdbook:<version>-rust`.

### Image Architectures

Only `amd64` is supported.

## Pre-built Images

- DockerHub: [hub.docker.com/r/lethang7794/mdbook]

  [![DockerHub Badge](https://dockeri.co/image/lethang7794/mdbook)][hub.docker.com/r/lethang7794/mdbook]

- GitHub's Container registry: [ghcr.io/lethang7794/mdbook]

  [![latest size](https://ghcr-badge.egpl.dev/lethang7794/mdbook/size?color=%2344cc11&tag=latest&label=latest&trim=)](https://github.com/lethang7794/docker-mdbook/pkgs/container/mdbook/versions)
  [![latest-rust size](https://ghcr-badge.egpl.dev/lethang7794/mdbook/size?color=%2344cc11&tag=latest-rust&label=latest-rust&trim=)](https://github.com/lethang7794/docker-mdbook/pkgs/container/mdbook/versions)

## Pre-installed software

- `mdbook`

- Preprocessors for mdBook:

  - [mdbook-mermaid]
  - [mdbook-toc]
  - [mdbook-admonish]
  - [mdbook-alerts]
  - [mdbook-pagetoc]
  - [mdbook-yml-header]

## How to use this Dockerfile

### Build your own images

- Run `make build`

### Use pre-built images

- See [Pre-built Images](#pre-built-images) section.

## How to use the images built from this Dockerfile

### Run the image directly

- Change directory to the root of your mdbook

  - It's the directory with `book.toml` file.

  - If you haven't have a mdbook yet, you can:

    - Use the example mdbook in the `example` of this repository.

      ```bash
      cd example
      ```

    - Or create one with this Docker image

      ```bash
      docker run -it --rm --volume="$PWD":/app --name=mdbook-container lethang7794/mdbook:v0.4.40-amd64 mdbook init
      ```

      See [Creating a Book | User Guide - mdBook Documentation](https://rust-lang.github.io/mdBook/guide/creating.html)

- Serve the book at <http://localhost:3000>

  ```bash
  docker run -it --rm --volume="$PWD":/app --publish=3000:3000 --name=mdbook-container lethang7794/mdbook:v0.4.40-amd64 mdbook serve --hostname=0.0.0.0
  ```

> [!WARNING]
> To allow run any pre-installed commands easily, the Dockerfile use `CMD` directory instead of `ENTRYPOINT`.
>
> - This cause the process running inside the container can NOT be killed with `Ctrl+C`.

> [!TIP]
> If you want to kill the mdbook server, kill the `mdbook-container`:
>
> ```bash
> docker kill mdbook-container
> ```

- Build the book (to the `book` directory in your host mdbook directory):

  ```bash
  docker run -it --rm --volume="$PWD":/app --publish=3000:3000 --name=mdbook-container lethang7794/mdbook:v0.4.40-amd64 mdbook build
  ```

### Run the image via a compose file

- Change directory to the root of your mdbook

  - It's the directory with `book.toml` file.

  - If you haven't have a mdbook yet, you can:

    - Use the example mdbook in the `example` of this repository.

      ```bash
      cd example
      ```

    - Or create one with this Docker image

      ```bash
      docker compose run --rm mdbook init
      ```

- Add a `compose.yml` file:

  ```yaml
  services:
    mdbook-service:
      container_name: mdbook-container
      image: lethang7794/mdbook:v0.4.40-amd64
      stdin_open: true
      tty: true
      ports:
        - 3000:3000
        - 3001:3001
      volumes:
        - ${PWD}:/app
      command:
        - serve
        - --hostname
        - "0.0.0.0"
        - --watcher
        - native
  ```

  See the example [`compose.yml`](https://github.com/lethang7794/docker-mdbook/blob/main/example/compose.yml) in the `example` directory.

- Serves a book at http://localhost:3000, and rebuilds it on changes

  ```
  docker compose up
  ```

> [!TIP]
> When serve the book with docker compose, you can press `Ctrl+C` to kill the server.

- Build the book (to the `book` directory in your mdbook directory):

  ```
  docker compose run --rm mdbook build
  ```

## Credits

- [peaceiris/docker-mdbook]

## License

- [MIT License]

[mdBook]: https://github.com/rust-lang/mdBook
[hub.docker.com/r/lethang7794/mdbook]: https://hub.docker.com/r/lethang7794/mdbook
[ghcr.io/lethang7794/mdbook]: https://github.com/users/lethang7794/packages/container/package/mdbook
[mdbook-mermaid]: https://github.com/badboy/mdbook-mermaid
[mdbook-toc]: https://github.com/badboy/mdbook-toc
[mdbook-admonish]: https://github.com/tommilligan/mdbook-admonish
[mdbook-alerts]: https://github.com/lambdalisue/rs-mdbook-alerts
[mdbook-pagetoc]: https://github.com/slowsage/mdbook-pagetoc
[mdbook-yml-header]: https://github.com/dvogt23/mdbook-yml-header
[peaceiris/docker-mdbook]: https://github.com/peaceiris/actions-mdbook
[the `alpine` official image]: https://hub.docker.com/_/alpine
[MIT License]: https://github.com/lethang7794/docker-mdbook/blob/main/LICENSE

[^1]: Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.
