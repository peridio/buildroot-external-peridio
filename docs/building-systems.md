# Building Systems

Clone repositories.

```bash
git clone git://git.buildroot.org/buildroot -b 2022.05
git clone git@github.com:peridio/buildroot-external-peridio
```

Build the system, setting or replacing the leveraged environment variables.

```bash
make \
  -C $BUILDROOT_REPOSITORY_DIRECTORY \
  BR2_EXTERNAL=$BUILDROOT_EXTERNAL_DIRECTORY \
  O=$BUILDROOT_OUTPUT_DIRECTORY \
  $BUILDROOT_DEFCONFIG

cd $BUILDROOT_OUTPUT_DIRECTORY

make
```
