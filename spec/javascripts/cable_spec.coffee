describe 'Collaborate.Cable', ->
  beforeEach =>
    cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(cable, 'DocumentChannel', 1)
    @collaborativeAttribute = @collaborate.addAttribute('body')

    @collaborateCable = @collaborate.cable

  describe 'on connection', =>
    it 'should send the document id', (done) =>
      spyOn(@collaborateCable.subscription, 'perform')

      @collaborateCable.connected()

      setTimeout =>
        expect(@collaborateCable.subscription.perform).toHaveBeenCalledWith('document', id: 1)
        done()
      , 1010

  describe 'on receive', =>
    describe 'subscription', =>
      it 'should set the client id', =>
        @collaborateCable.received(action: 'subscribed', client_id: 1)

        expect(@collaborateCable.clientId).toEqual(1)

    describe 'receiveAttribute', =>
      it "should warn if the attribute hasn't been registered", =>
        spyOn(console, 'warn')

        @collaborateCable.received(document_id: 1, action: 'attribute', attribute: 'title')

        expect(console.warn).toHaveBeenCalled()

      it 'should delegate to the attribute cable', =>
        spyOn(@collaborativeAttribute.cable, 'receiveAttribute')

        @collaborateCable.received(document_id: 1, action: 'attribute', attribute: 'body')

        expect(@collaborativeAttribute.cable.receiveAttribute).toHaveBeenCalled()

    describe 'receiveOperation', =>
      it "should warn if the attribute hasn't been registered", =>
        spyOn(console, 'warn')

        @collaborateCable.received(document_id: 1, action: 'operation', attribute: 'title')

        expect(console.warn).toHaveBeenCalled()

      it 'should delegate to the attribute cable', =>
        spyOn(@collaborativeAttribute.cable, 'receiveOperation')

        @collaborateCable.received(document_id: 1, action: 'operation', attribute: 'body')

        expect(@collaborativeAttribute.cable.receiveOperation).toHaveBeenCalled()

  it "should warn about any received messages we haven't handled", =>
    spyOn(console, 'warn')

    @collaborateCable.received(action: 'other')

    expect(console.warn).toHaveBeenCalled()
