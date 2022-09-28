!/usr/bin/env sh

# build new site
hugo new site --force ./ -f yml

# get papermod theme
git clone https://github.com/adityatelange/hugo-PaperMod themes/PaperMod --depth=1

# update theme
cd themes/PaperMod
git pull

# copy config
cp config.yml ../config.yml

# enable math rendering
cp footer.html ../themes/PaperMod/layouts/partials/footer.html