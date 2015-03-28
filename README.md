# TGFF

Hosting for [TGFF][1] (Task Graphs For Free). Refer to the original
[README](README) for further details.

## Compilation

Running `make` directly fails as the code is not compatible with modern
compilers. Patching is required.

```shell
curl https://raw.githubusercontent.com/copies/tgff/patch/v3.5.patch | git apply
make
```

[1]: http://ziyang.eecs.umich.edu/~dickrp/tgff/
