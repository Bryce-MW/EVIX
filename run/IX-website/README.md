# IX-website
Jinja2 templates for IXP (Internet Exchange Point) websites.

### Install

*Tested on python 3.6.x*

```
pip install staticjinja2
```

### Configuration

Some website content is modified through the config file `templates/globals.yaml`. The rest will have to be done manually through HTML.

We are planning to make the entire website content configurable through the `globals.yaml` file, however the following yaml settings currently work:

* Logos settings, contact emails, name, URL
* `ix_home.html` content


#### Modifying HTML content

For the pages where the content cannot yet be changed through yaml, make edits to the relevant template file under `templates/page/`.
For example, to modify the peers table, change the contents of `templates/page/ix_peers.html`.


### Usage 

To build into the `www/` directory after modifying the settings/templates according to your needs:

```
staticjinja build --srcpath=templates --static=static --outpath=www --globals=globals.yaml
```

# IXPs currently using IX-website:






* [![MonctonIX](http://monctonix.ca/static/img/logo.png)](http://monctonix.ca) 





