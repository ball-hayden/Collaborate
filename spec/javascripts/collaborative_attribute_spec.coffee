#= require collaborate

describe 'CollaborativeAttribute', ->
  beforeEach =>
    @cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(@cable, 'DocumentChannel', 'body')
    @collaborativeAttribute = @collaborate.addAttribute('body')

  it 'should start in the synchronized state', =>
    expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.Synchronized))

  describe 'localOperation', =>
    it 'should do nothing if the operation is a noop', =>
      spyOn(@collaborativeAttribute.state, 'localOperation')

      operation = new ot.TextOperation()

      @collaborativeAttribute.localOperation(operation)

      expect(@collaborativeAttribute.state.localOperation).not.toHaveBeenCalled()
