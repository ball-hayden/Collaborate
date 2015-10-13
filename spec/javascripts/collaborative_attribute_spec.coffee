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

    it 'should delegate localOperation to the current state', =>
      spyOn(@collaborativeAttribute.state, 'localOperation')

      operation = new ot.TextOperation()
      operation.insert('test')

      @collaborativeAttribute.localOperation(operation)

      expect(@collaborativeAttribute.state.localOperation).toHaveBeenCalled()

  it 'should call transformRemoteOperation on the current state', =>
    spyOn(@collaborativeAttribute.state, 'transformRemoteOperation')

    operation = new ot.TextOperation()
    operation.insert('test')

    @collaborativeAttribute.remoteOperation(operation)

    expect(@collaborativeAttribute.state.transformRemoteOperation).toHaveBeenCalled()

  it 'should delegate receiveAck to the current state', =>
    spyOn(@collaborativeAttribute.state, 'receiveAck')

    operation = new ot.TextOperation()
    operation.insert('test')

    @collaborativeAttribute.receiveAck(operation)

    expect(@collaborativeAttribute.state.receiveAck).toHaveBeenCalled()
