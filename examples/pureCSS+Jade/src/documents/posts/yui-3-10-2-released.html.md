---
layout: post
title: YUI 3.10.2 Released
author: Andrew Wooldridge
tags: ['YUI']
---

We are happy to announce the release of YUI 3.10.2! You can find it now on the Yahoo! CDN, download it directly, or pull it in via npm. We've also updated the YUI Library website with the latest documentation.

Since we've had a number of larger releases lately, this release represents an effort to do some "spring cleaning" on the codebase. Behind the scenes we've also been working hard on our CI system. We've been digging deep into flaky browser tests to ensure that we have the highest confidence in future releases across our supported YUI Target Environments.

Given the "cleanup" nature of this release, there are updates and fixes across the board.

## Anim Fix

YUI contributor Zeno Rocha (from Liferay) removed an unnecessary code tag in the Anim Utility.

## App Framework Fix

In the App Framework, Router now properly dispatches when using hash-based URLS and calling replace() without arguments. Before this would throw an error.

## Attribute Fix

In YUI 3.8.1 there was a fix to ensure options were sent to the setter correctly in Attribute, but this didn't work using AttributeObservable and is now fixed in this version.

## Charts Fixes

Two issues were fixed in Charts. In the first, styles didn't map correctly to a legend when series were styled using a global object. In the second, the legend would not honor the specified series marker style for shape.

## Color Changes

This is a relatively larger change that you may want to take note of. Y.Color was moved out of DOM. You may observe some minor differences in the output of Y.Color methods. So if you were depending on a specific type of response, for instance toHex(), you may want to check your own implementations. See pull request 822 for more details.

## Dial Fixes

There was a minor bug fix in Dial where it may stick at min if you dragged it below min, then back above min - but only if the min/max position was North of the dial.

## Event and Custom Event Fixes

One area that received a lot of attention this time around were the Event and Custom Event modules. The nodelist.on() method had a rare issue with custom module loading. There was a fix for DOM event facade when the Y instance was set to emitFacade:true (see release notes for details). In Custom Event there was an issue fixed regarding the facade carrying stale data for the "no subscriber" case. A Custom Event regression was fixed where once() and onceAfter() subscriptions using the * prefix threw a TypeError. Finally, there was an exception fixed with fire(type,null) with emitFacade:true.

## JSON Fix

YUI Reviewer Luke Smith fixed an issue in the JSON utility that would effect YUICompressor and code minification. There are efforts (see issues 4 and 5) underway to guarantee CDN files are tested.

## Graphics Fix

There was a rounding issue fixed in the SVG implementation that had surfaced in certain edge cases of the PieChart in the Charts module.