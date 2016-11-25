import urllib
test = urllib.urlretrieve("http://iteam.imgix.net/oval.png?txtclr=ffffff&txt=TesT&txtfit=max&txtsize=200&txtalign=center,middle&txtfont=PT%20Serif,Bold", "test.png")
print(test)
