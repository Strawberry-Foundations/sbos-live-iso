<div align="center">
    <h1>StrawberryOS Live ISO</h1>
    <a href="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/testing.yml">
        <img src="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/testing.yml/badge.svg">
    </a>
    <a href="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/snapshot.yml">
        <img src="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/snapshot.yml/badge.svg">
    </a>
</div>

## Building Locally

The following example uses Docker and assumes you have Docker correctly installed and set up:

 1) Clone this project & `cd` into it:

    ```
    $ git clone https://github.com/Strawberry-Foundations/ sbos-live-iso && cd sbos-live-iso
    ```

 2) Run the build:

    ```
    $ bash run_container.sh
    ```

 3) When done, your image will be in the `builds` folder.