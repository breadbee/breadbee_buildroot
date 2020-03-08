#!/usr/bin/env python3

import argparse
import os
import subprocess
import pathlib
import string
import shutil

fit_cfg_template = string.Template("${name} { fdt = \"${name}_overlay\"; };\n")
fit_ovrly_template = string.Template(
    "${name}_overlay {\n"
    " data = /incbin/(\"${dtb}\");\n"
    " type = \"flat_dt\";\n"
    " arch = \"arm\";\n"
    " compression = \"none\";\n"
    " load = <${load_offset}>;\n"
    " hash@0 {algo = \"crc32\";};\n"
    " hash@1 {algo = \"sha1\";};\n"
    "};\n")


def compile_dts(dts):
    dts_preproccessed = dts.with_suffix(".dts_pp")
    gcc_args = [args.cpp, "-nostdinc", "-I", args.bindings, "-undef,", "-x", "assembler-with-cpp", str(dts.absolute()),
                "-o",
                str(dts_preproccessed.absolute())]
    print("Pre-processing %s to %s with %s" % (dts, dts_preproccessed, " ".join(gcc_args)))
    assert subprocess.run(gcc_args).returncode == 0

    dtb = dts.with_suffix(".dtb")
    dtc_args = [args.dtc, "-@", "-a", "4", "-I", "dts", "-O", "dtb", "-o", str(dtb.absolute()),
                str(dts_preproccessed.absolute())]
    print("Compiling %s to %s with %s" % (dts_preproccessed, dtb, " ".join(dtc_args)))
    assert subprocess.run(dtc_args).returncode == 0
    return dtb


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--cpp", required=True)
    parser.add_argument("--bindings", required=True)
    parser.add_argument("--dtc", required=True)
    parser.add_argument("--overlays", required=True)
    parser.add_argument("--imggenoutputs", required=True)

    args = parser.parse_args()

    imggenoutputs = pathlib.Path(args.imggenoutputs)
    if imggenoutputs.exists():
        shutil.rmtree(imggenoutputs)
    imggenoutputs.mkdir(parents=True)

    dts_dir = pathlib.Path(args.overlays)

    fdtlist = ""
    conflist = ""

    load_offset = 0x23008000

    for ovl in os.listdir(dts_dir):
        if ovl.endswith(".dts"):
            dts_path = dts_dir / ovl
            dtb = compile_dts(dts_path)

            fdtlist += fit_ovrly_template.substitute(name=dts_path.stem, dtb=dtb.absolute(),
                                                     load_offset="0x%x" % load_offset)
            conflist += fit_cfg_template.substitute(name=dts_path.stem)

            load_offset += dtb.stat().st_size

            assert load_offset % 4 == 0

            continue
        else:
            continue

    fdt_path = imggenoutputs / "fdtlist"
    with open(fdt_path, "w") as f:
        f.write(fdtlist)

    conf_path = imggenoutputs / "configlist"

    with open(conf_path, "w") as f:
        f.write(conflist)
