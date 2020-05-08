# covid19_risk

This repo contains a sample final project. There are a couple of suggestions I have for folks to consider as they finish the project:

1. Separate out your data cleaning code and mapping code into two different notes. My `docs/clean_data.Rmd` does all the data cleaning work, and writes the final data to my `data/` folder. Then, I load those data in `risk_mapping.Rmd` in the initial code chunk. 
2. Make sure line 5 of your mapping notebook has the output structured like so: `output: html_document`. This will ensure that your output can be opened in a web-browser and used interactively.
3. Code chunks in your mapping notebook that contain maps to output should have the initial line structured like so: `{r over65, echo=FALSE, out.width = '100%'}`. This will prevent your code from appearing in the final notebook (`echo=FALSE`). It will also make sure the maps take up the full width of the page.