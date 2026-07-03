help([[
JEDI Bundle
Commit: 5a0d9257a258b9954a44593285df20add0d6416d
]])

whatis("Name: JEDI Bundle")
whatis("Version: 5a0d925")

prepend_path("MODULEPATH",
             "/opt/spack-stack/envs/fv3jedi-2.1/modules/Core")

load("stack-gcc/13.3.0")
load("stack-openmpi/5.0.8")
load("jedi-fv3-env/1.0.0")

local root="/home/jonggyunkim/git/jedi-build/jedi-bundle/build"

setenv("JEDI_BUNDLE_ROOT", root)

prepend_path("PATH", pathJoin(root, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))