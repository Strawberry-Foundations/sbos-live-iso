<div align="center">
    <h1>StrawberryOS Live ISO</h1>
    <a href="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/testing.yml">
        <img src="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/testing.yml/badge.svg">
    </a>
    <a href="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/snapshot.yml">
        <img src="https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/snapshot.yml/badge.svg">
    </a>
</div>

## Tested Builds
You can download tested builds from our [GitHub releases](https://github.com/Strawberry-Foundations/sbos-live-iso/releases). These are usually more stable and have been tested by us developers. 

## Untested Builds
Untested builds can be downloaded directly from [GitHub Actions](https://github.com/Strawberry-Foundations/sbos-live-iso/actions/workflows/testing.yml). You will need a GitHub account for this. These builds are usually not tested and could therefore be susceptible to bugs.


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