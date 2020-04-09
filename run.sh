# run only on master

# check versions
Rscript --version

# prepare and update docs
git clone -b docs --single-branch ${CI_REPOSITORY_URL} output
cp -f README.md output/README.md

# clone hopkins
mkdir -p input
git clone https://github.com/CSSEGISandData/COVID-19.git input/hopkins

# transform hopkins
mkdir -p output
mkdir -p r_libs
Rscript.exe ./R/transform-hopkins-data.R

# push docs
cd output
git config user.name runner_${CI_RUNNER_ID}
git config user.email "notexist@insysbio.com"
git add --all
git commit --allow-empty -m "created based on commit ${CI_COMMIT_SHORT_SHA}"
git push ${CI_REPOSITORY_URL} HEAD:docs
