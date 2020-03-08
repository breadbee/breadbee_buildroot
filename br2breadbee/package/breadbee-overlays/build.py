#!/usr/bin/env python3

import argparse
import os
import subprocess
import pathlib
import string
import shutil
import json

valid_keys = ["names", "targets", "expansion"]
valid_types = ["connector", "interface", "device", "config"]


def expansion_eitheror(values, targets):
    assert len(values) == len(targets)

    e = []
    for i in range(len(values)):
        e.append({"name": values[i], "target": targets[i], "pinctrl": None})

    return e


def expansion_sar(values, targets):
    e = []
    for i in range(1, 2 ** len(values)):
        s = []
        for j in range(len(values)):
            if i >> j & 1 == 1:
                s.append(values[j])
        e.append({"name": "-".join(s), "target": None, "pinctrl": s})
    return e


expansions = {"sar": expansion_sar, "eitheror": expansion_eitheror}


def process_template(tmpl_path: pathlib.Path):
    tmpl_tokens = {}

    with open(tmpl_path) as f:
        tmpl = ""
        for l in f.readlines():
            if l.startswith("//bbtmpl-"):
                l = l.strip()
                kv = l.split(":")

                k = kv[0].split("-")[1]

                assert k in valid_keys

                v = kv[1].split(",")

                tmpl_tokens[k] = v
            else:
                tmpl += l

    expansion = tmpl_tokens.get("expansion")[0]
    names = tmpl_tokens.get("names")
    targets = tmpl_tokens.get("targets")

    assert expansion in expansions
    assert names is not None

    ex = expansions[expansion](names, targets)

    tmpl = string.Template(tmpl)

    for e in ex:
        file_name = tmpl_path.stem + "_" + e["name"] + ".dts"
        file_path = tmpl_path.parent / file_name
        with open(file_path, "w") as dts:
            pinctrl = None
            if e["pinctrl"] is not None:
                pinctrl = ",".join(map(lambda x: "<&%s_pins>" % x, e["pinctrl"]))
            dts.write(tmpl.substitute(pinctrl=pinctrl, target=e["target"]))


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


def extract_tokens(dts):
    tokens = {}
    with open(dts) as f:
        for l in f.readlines():
            if l.startswith("//bbovly-"):
                kv = l.split("-")[1].split(":")
                assert len(kv) == 2
                tokens[kv[0]] = kv[1].strip()
                pass
    return tokens


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
    parser.add_argument("--beecfg_outputs", required=True)
    parser.add_argument('category', nargs='*')

    args = parser.parse_args()

    imggenoutputs = pathlib.Path(args.imggenoutputs)
    if imggenoutputs.exists():
        shutil.rmtree(imggenoutputs)
    imggenoutputs.mkdir(parents=True)

    beecfg_outputs_path = pathlib.Path(args.beecfg_outputs)

    dts_dir = pathlib.Path(args.overlays)

    fdtlist = ""
    conflist = ""
    dtb_heap = {}
    load_offset = 0x23008000

    for tmpl in sorted(os.listdir(dts_dir)):
        if tmpl.endswith(".tmpl"):
            process_template(pathlib.Path(dts_dir / tmpl))

    for ovl in sorted(os.listdir(dts_dir)):
        if ovl.endswith(".dts"):
            print("Processing overlay %s" % ovl)
            dts_path = dts_dir / ovl

            dts_name = dts_path.stem

            tokens = extract_tokens(dts_path)

            category = tokens.get("category")
            type = tokens.get("type")

            assert category is not None
            assert type in valid_types

            if category not in args.category:
                print("Skipping %s, %s not in selected categories (%s)" % (category, dts_path, ",".join(args.category)))
                continue

            dtb = compile_dts(dts_path)

            fdtlist += fit_ovrly_template.substitute(name=dts_name, dtb=dtb.absolute(),
                                                     load_offset="0x%x" % load_offset)
            conflist += fit_cfg_template.substitute(name=dts_name)

            # push the load offset forward and make sure it's 4 byte aligned
            load_offset += dtb.stat().st_size
            assert load_offset % 4 == 0

            dtb_heap[dts_name] = tokens

    fdt_path = imggenoutputs / "fdtlist"
    with open(fdt_path, "w") as f:
        f.write(fdtlist)

    conf_path = imggenoutputs / "configlist"

    with open(conf_path, "w") as f:
        f.write(conflist)

    categories = {}
    categories_path = beecfg_outputs_path / "categories.json"

    with open(categories_path, "w") as f:
        json.dump(categories, f, indent=4)

    interfaces = {}
    interfaces_path = beecfg_outputs_path / "interfaces.json"

    with open(interfaces_path, "w") as f:
        json.dump(interfaces, f, indent=4)
