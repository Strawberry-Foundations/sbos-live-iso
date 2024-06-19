<div align="center">
    <h1>StrawberryOS Todo's</h1>
    <i>
        A list of features, improvements & bug fixes relevant for StrawberryOS's future releases
    </i>
    <br><br>
</div>

# Todo's for the next release of StrawberryOS (Beta 4)
## Needs to be done
- Recovery mode for StrawberryOS
- Custom /etc/motd
- Restore option for somgr's backup function

## Done
- ✅ Extended Strawberry Cloud support for somgr
- ✅ Different PS1 variable for userspace
- ✅ Fix install-sbos bash script (Pass arguments)
- ✅ Fix dev flags for StrawberryOS installer (Invalid argument parsing)
- ✅ Fix invalid chroot path for somgr's apt lock feature
- ✅ Custom /etc/issue


# Todo's & Ideas for future releases of StrawberryOS
- Apt tweaking so that apt does not show in userspace that certain packages are NOT going to be upgraded
    - Option 1: Program your own apt version that no longer displays these packages 
    - Option 2: When upgrading the system partition, the package differences between user space and system space should be compared and if there are differences between the versions, the newer version or the version from the system space is automatically used