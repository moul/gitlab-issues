#!/usr/bin/env coffee

{ApiV3} =  require 'gitlab'
optimist = require 'optimist'

argv = optimist
  .usage('Usage: $0 [-v] -u <url> -t <token>')
  .alias('v', 'verbose').describe('v', 'Verbose').boolean('v')
  .alias('u', 'url').describe('u', 'Gitlab url')
  .alias('t', 'token').describe('t', 'Api token')
  .alias('c', 'clear').describe('c', 'Clear terminal').boolean('c')
  .alias('s', 'no-verify-ssl').describe('s', 'Disable strict SSL').boolean('s')
  .demand(['u', 't'])
  .argv

if argv.clear
  process.stdout.write '\u001B[2J\u001B[0;0f'

gitlab = new ApiV3
  url:          argv.url
  token:        argv.token
  verbose:      argv.verbose
  'strict-ssl': !argv.s

gitlab.projects.all (projects) ->
  console.log projects.length
