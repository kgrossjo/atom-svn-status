{WorkspaceView} = require 'atom'
AtomSvn = require '../lib/atom-svn'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomSvn", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('atom-svn')

  describe "when the atom-svn:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.atom-svn')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'atom-svn:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.atom-svn')).toExist()
        atom.workspaceView.trigger 'atom-svn:toggle'
        expect(atom.workspaceView.find('.atom-svn')).not.toExist()
