---
layout: post
title: CMS plugin for DocPad
author: Steve McArthur 
tags: ['DocPad']
---
This example website shows how the [docpad-plugin-cms](https://www.npmjs.com/package/docpad-plugin-cms) works with any responsive/CSS/HTML framework and any DocPad templating system that may be used by a website. The CMS interface itself uses the [bootstrap framework](http://getbootstrap.com/) and the [ECO templating](https://www.npmjs.com/package/docpad-plugin-eco) system, but is isolated from whatever the website uses itself. 

However, to function properly a number of supporting plugins need to be installed. The ECO plugin is needed to render the CMS interface and this plugin can be installed alongside whatever template plugin that is installed already. In this case, the [Jade plugin](https://www.npmjs.com/package/docpad-plugin-jade).

Other plugins that need to be installed are the [cleanurls](https://www.npmjs.com/package/docpad-plugin-cleanurls) and [posteditor](https://www.npmjs.com/package/docpad-plugin-posteditor) plugins. The cleanurls plugin is usually a good one to install anyway - so it is likely you will have it already. The posteditor plugin provides the functionality for editing posts - typically the most important function within a CMS.

The [authentication plugin](https://www.npmjs.com/package/docpad-plugin-authentication) is also expected to be installed, but technically you could argue that this is not essential for the operation of the CMS plugin. It just provides a way of protecting the CMS pages from unauthenticated users.

If the eco, authentication, cleanurls and posteditor plugins are not present then a warning will be issued through the console highlighting the fact that these plugins are missing.

The eco, cleanurls and posteditor plugins are also listed as 'peerDependencies' in the package.json. So node will also output a big red message highlighting these 'unmet peerDependencies'.

There is also an 'analytics' page within the CMS and analytics data shown on the CMS dashboard. These require the [analytics plugin](https://www.npmjs.com/package/docpad-plugin-analytics) to be installed. If not, these functions will not be present and a message will appear on the dashboard stating that the analytics plugin is not installed.

Likewise, there is also a 'plugins' page within the CMS, used for managing a DocPad website's installed plugins. This expects the [pluginmanager plugin](https://www.npmjs.com/package/docpad-plugin-pluginmanager) to be installed. If not, the page will not be present and a message will appear on the dashboard.

The plugins, therefore, that are either required or recommended to be installed are:

* ECO [https://www.npmjs.com/package/docpad-plugin-eco](https://www.npmjs.com/package/docpad-plugin-eco)
* Cleanurls [https://www.npmjs.com/package/docpad-plugin-cleanurls](https://www.npmjs.com/package/docpad-plugin-cleanurls)
* Posteditor [https://www.npmjs.com/package/docpad-plugin-posteditor](https://www.npmjs.com/package/docpad-plugin-posteditor)
* Authentication [https://www.npmjs.com/package/docpad-plugin-authentication](https://www.npmjs.com/package/docpad-plugin-authentication)
* Analytics [https://www.npmjs.com/package/docpad-plugin-analytics](https://www.npmjs.com/package/docpad-plugin-analytics)
* Pluginmanager [https://www.npmjs.com/package/docpad-plugin-pluginmanager](https://www.npmjs.com/package/docpad-plugin-pluginmanager)

The order in which the plugins are installed doesn't really matter, but to avoid any warning messages and unexpected behaviour by the CMS you are probably better off installing the above plugins first.

