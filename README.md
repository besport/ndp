Natural Date Processing
=======================
Natural Date Processing is a small library written in CoffeeScript, allowing you to read user inputs and guess when things will happen.

Installation
============

You can grab the `date.js` file at the root of the project, or compile it yourself.

Usage
=====

Easy, one method and you're done : `Date.parse("why not next monday at 17 pm?")`

Compilation
===========

  * If you have Yeoman, simply `run yeoman concat:coffee coffee:build` and grab the output file
  * If you don't have it, run `cat app/scripts/date.*.coffee | coffee -s -o . > date.js`
