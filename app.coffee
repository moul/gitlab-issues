#!/usr/bin/env coffee

{ApiV3} =  require 'gitlab'
optimist = require 'optimist'
async =    require 'async'

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
  project_ids = [project.id for project in projects][0]

  # reduce function, called asynchronously for each projects
  iterator = (memo, project_id, callback) ->
    gitlab.projects.issues.list project_id, (issues) ->
      if argv.verbose and issues.length
        console.log "Project id: #{project_id}, new issues #{issues.length}"
      process.nextTick ->
        callback null, memo.concat(issues)

  # asynchronous call
  async.reduce project_ids, [], iterator, (err, issues) ->
    if err
      console.err err
      process.exit -1

    #console.log 'issues', issues.length
    console.log JSON.stringify issues