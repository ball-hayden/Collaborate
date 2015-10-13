#= require collaborate

describe 'CollaborativeAttribute.AwaitingWithBuffer', ->
  beforeEach =>
    cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(cable, 'DocumentChannel', 1)

    @collaborativeAttribute = @collaborate.addAttribute('body')
    @attributeCable = @collaborativeAttribute.cable

    @demoLocalOperation = (new ot.TextOperation()).insert('t')
    @demoBuffer = (new ot.TextOperation()).retain(1).insert('est')

    @state = @collaborativeAttribute.state =
      new Collaborate.CollaborativeAttribute.AwaitingWithBuffer(@collaborativeAttribute, @demoLocalOperation, @demoBuffer)

  describe 'localOperation', =>
    beforeEach =>
      @demoExtraOperation = (new ot.TextOperation()).retain(4).insert('ing')

    it 'should not send the operation to the attribute cable', =>
      spyOn(@attributeCable, 'sendOperation')

      @state.localOperation(@demoExtraOperation)
      expect(@attributeCable.sendOperation).not.toHaveBeenCalled()

    it 'should remain in the AwaitingWithBuffer state', =>
      @state.localOperation(@demoExtraOperation)

      expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.AwaitingWithBuffer))
      expect(@collaborativeAttribute.state.operation).toEqual(@demoLocalOperation)

    it 'should compose the current buffer with the new operation', =>
      @state.localOperation(@demoExtraOperation)

      composedOperation = (new ot.TextOperation()).retain(1).insert('esting')

      expect(@collaborativeAttribute.state.buffer).toEqual(composedOperation)

  it 'should return to the AwaitingAck state following an ack', =>
    @state.receiveAck()

    expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.AwaitingAck))
    expect(@collaborativeAttribute.state.operation).toEqual(@demoBuffer)

  describe 'remoteOperation', =>
    beforeEach =>
      @receiveData =
        operation: (new ot.TextOperation()).insert('ing')

      @state.transformRemoteOperation(@receiveData)

    it 'should transform a remote operation against our pending operation', =>
      expect(@receiveData.operation.apply('test')).toEqual('testing')
      expect(@state.operation.apply('ing')).toEqual('ting')
      expect(@state.buffer.apply('ting')).toEqual('testing')

    it 'should remain in the AwaitingWithBuffer state', =>
      expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.AwaitingWithBuffer))
