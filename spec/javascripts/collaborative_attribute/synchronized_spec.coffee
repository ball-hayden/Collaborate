#= require collaborate

describe 'CollaborativeAttribute.Synchronized', ->
  beforeEach =>
    cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(cable, 'DocumentChannel', 1)

    @collaborativeAttribute = @collaborate.addAttribute('body')
    @attributeCable = @collaborativeAttribute.cable

    # To be explicit...
    @state = @collaborativeAttribute.state =
      new Collaborate.CollaborativeAttribute.Synchronized(@collaborativeAttribute)

    @demoOperation = (new ot.TextOperation()).insert('test')

  describe 'localOperation', =>
    it 'should send the operation to the attribute cable', =>
      spyOn(@attributeCable, 'sendOperation')

      @state.localOperation(@demoOperation)
      expect(@attributeCable.sendOperation).toHaveBeenCalledWith(operation: @demoOperation)

    it 'should set the current state to AwaitingAck', =>
      @state.localOperation(@demoOperation)

      expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.AwaitingAck))

  it 'should print to console if we received an ack', =>
    spyOn(console, 'error')

    @state.receiveAck(version: 'test')

    expect(console.error).toHaveBeenCalled()

  it 'should not change a remote operation', =>
    operation = (new ot.TextOperation()).insert('ing')

    receiveData =
      operation: operation

    @state.transformRemoteOperation(receiveData)

    expect(operation).toEqual(receiveData.operation)
