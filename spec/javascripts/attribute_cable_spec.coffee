describe 'Collaborate.AttributeCable', ->
  beforeEach =>
    cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(cable, 'DocumentChannel', 1)
    @collaborativeAttribute = @collaborate.addAttribute('body')

    @cable = @collaborate.cable
    @attributeCable = @collaborativeAttribute.cable

  it 'should register the attribute with the collaboration cable', =>
    expect(@cable.attributeCables['body']).toEqual @attributeCable

  it 'should store the attribute version when it receives the attribute', =>
    @attributeCable.receiveAttribute(version: 4)
    expect(@attributeCable.version).toEqual(4)

  describe 'sendOperation', =>
    beforeEach =>
      spyOn(@cable, 'sendOperation')

      @data =
        operation: new ot.TextOperation()

      @attributeCable.sendOperation(@data)

    it 'should increment the attribute version', =>
      expect(@attributeCable.version).toEqual(1)

    it 'should add the version and attribute name to the send data', =>
      expect(@data.version).toEqual(1)
      expect(@data.attribute).toEqual('body')

    it 'should add the version to the unackedOps list', =>
      expect(@attributeCable.unackedOps).toContain(1)

    it 'should send the operation to the collaboration cable', =>
      expect(@cable.sendOperation).toHaveBeenCalledWith(@data)

  describe 'receiveOperation', =>
    beforeEach =>
      @data =
        operation: new ot.TextOperation(),
        attribute: 'body',
        version: 3,

    it 'should set the attribute version to the version just received', =>
      @attributeCable.receiveOperation(@data)

      expect(@attributeCable.version).toEqual(3)

    it 'should call receiveAck if we sent the message', =>
      @data.client_id = @cable.clientId = 'test'
      spyOn(@attributeCable, 'receiveAck')

      @attributeCable.receiveOperation(@data)

      expect(@attributeCable.receiveAck).toHaveBeenCalled()

    it 'should call receiveAck if we sent the message', =>
      @cable.clientId = 'test'
      spyOn(@attributeCable, 'receiveRemoteOperation')

      @attributeCable.receiveOperation(@data)

      expect(@attributeCable.receiveRemoteOperation).toHaveBeenCalled()

  describe 'receiveAck', =>
    it "should log acks that we aren't expecting", =>
      spyOn(console, 'warn')

      @attributeCable.receiveAck(sent_version: 5)

      expect(console.warn).toHaveBeenCalled()

    it 'should delegate to the collaborative attribute', =>
      spyOn(@collaborativeAttribute, 'receiveAck')
      @attributeCable.unackedOps.push(1)

      @attributeCable.receiveAck(sent_version: 1)

      expect(@collaborativeAttribute.receiveAck).toHaveBeenCalled()

  describe 'receiveRemoteOperation', =>
    it 'should delegate to the collaborative attribute', =>
      @data =
        operation: new ot.TextOperation(),
        attribute: 'body',
        version: 3,

      spyOn(@collaborativeAttribute, 'remoteOperation')

      @attributeCable.receiveRemoteOperation(@data)

      expect(@collaborativeAttribute.remoteOperation).toHaveBeenCalled()

  describe 'destroy', =>
    it 'should remove itself from the cable attributes list', =>
      expect(Object.keys(@cable.attributeCables)).toContain('body')

      @attributeCable.destroy()

      expect(Object.keys(@cable.attributeCables)).not.toContain('body')
