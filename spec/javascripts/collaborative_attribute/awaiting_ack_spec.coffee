#= require collaborate

describe 'CollaborativeAttribute.AwaitingAck', ->
  beforeEach =>
    cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(cable, 'DocumentChannel', 1)

    @collaborativeAttribute = @collaborate.addAttribute('body')
    @attributeCable = @collaborativeAttribute.cable

    @demoOperation1 = (new ot.TextOperation()).insert('test')

    @state = @collaborativeAttribute.state =
      new Collaborate.CollaborativeAttribute.AwaitingAck(@collaborativeAttribute, @demoOperation1)

  describe 'localOperation', =>
    beforeEach =>
      @demoOperation2 = (new ot.TextOperation()).retain(4).insert('ing')

    it 'should not send the operation to the attribute cable', =>
      spyOn(@attributeCable, 'sendOperation')

      @state.localOperation(@demoOperation2)
      expect(@attributeCable.sendOperation).not.toHaveBeenCalled()

    it 'should set the current state to AwaitingWithBuffer', =>
      @state.localOperation(@demoOperation2)

      expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.AwaitingWithBuffer))

      expect(@collaborativeAttribute.state.operation).toEqual(@demoOperation1)
      expect(@collaborativeAttribute.state.buffer).toEqual(@demoOperation2)

  it 'should return to the Synchronized state following an ack', =>
    @state.receiveAck()

    expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.Synchronized))

  describe 'remoteOperation', =>
    beforeEach =>
      @receiveData =
        operation: (new ot.TextOperation()).insert('ing')

      @state.transformRemoteOperation(@receiveData)

    it 'should transform a remote operation against our pending operation', =>
      expect(@receiveData.operation.apply('test')).toEqual('testing')
      expect(@state.operation.apply('ing')).toEqual('testing')

    it 'should remain in the AwaitingAck state', =>
      expect(@collaborativeAttribute.state).toEqual(jasmine.any(Collaborate.CollaborativeAttribute.AwaitingAck))
