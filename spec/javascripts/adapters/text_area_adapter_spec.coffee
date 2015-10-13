#= require collaborate

describe 'Adapters.TextAreaAdapter', ->
  beforeEach =>
    @cable = Cable.createConsumer "ws://localhost:28080"
    @collaborate = new Collaborate(@cable, 'DocumentChannel', 'body')
    @collaborativeAttribute = @collaborate.addAttribute('body')

    fixture.set('<textarea></textarea>')
    @textArea = $('textarea', fixture.el)

    @adapter = new Collaborate.Adapters.TextAreaAdapter(@collaborativeAttribute, @textArea)

  it 'should respond to text changes', =>
    spyOn(@collaborativeAttribute, 'localOperation')
    @textArea.val('test')

    @textArea.trigger('keyup')

    expect(@collaborativeAttribute.localOperation).toHaveBeenCalled()

  describe 'generating an OT operation from a text change', =>
    it 'should be able to insert new text', =>
      operation = @adapter.operationFromTextChange('', 'test')
      expectedOperation = (new ot.TextOperation()).insert('test')

      expect(operation.equals(expectedOperation))

    it 'should be able to handle insert operations at the beginning of the existing text', =>
      operation = @adapter.operationFromTextChange('ing', 'testing')
      expectedOperation = (new ot.TextOperation()).insert('test').retain(3)

      expect(operation.equals(expectedOperation))

    it 'should be able to handle insert operations in the middle of the existing text', =>
      operation = @adapter.operationFromTextChange('test123', 'testing123')
      expectedOperation = (new ot.TextOperation()).retain(4).insert('ing').retain(3)

      expect(operation.equals(expectedOperation))

    it 'should be able to handle insert operations at the end of the existing text', =>
      operation = @adapter.operationFromTextChange('test', 'testing\n\n123')
      expectedOperation = (new ot.TextOperation()).retain(4).insert('ing\n\n123')

      expect(operation.equals(expectedOperation))

    it 'should be able to handle delete operations at the start', =>
      operation = @adapter.operationFromTextChange('test123', '123')
      expectedOperation = (new ot.TextOperation()).delete(4).retain(3)

      expect(operation.equals(expectedOperation))

    it 'should be able to handle delete operations in the middle', =>
      operation = @adapter.operationFromTextChange('testing123', 'test123')
      expectedOperation = (new ot.TextOperation()).retain(4).delete(3).retain(3)

      expect(operation.equals(expectedOperation))

    it 'should be able to handle delete operations at the end', =>
      operation = @adapter.operationFromTextChange('testing\n\n123', 'test')
      expectedOperation = (new ot.TextOperation()).retain(4).delete(8)

      expect(operation.equals(expectedOperation))

    it 'should be able to delete all text', =>
      operation = @adapter.operationFromTextChange('testing', '')
      expectedOperation = (new ot.TextOperation()).delete(7)

      expect(operation.equals(expectedOperation))

    it 'should generate a noop if nothing has changed', =>
      operation = @adapter.operationFromTextChange('test', 'test')

      expect(operation.isNoop())

  describe 'applying remote changes', =>
    beforeEach =>
      @textArea.val('test')
      @adapter.oldContent = 'test'
      @textArea[0].selectionStart = 4

      operation = (new ot.TextOperation()).retain(4).insert('ing')

      @adapter.applyRemoteOperation(operation)

    it 'should update the content of the textArea', =>
      expect(@textArea.val()).toEqual('testing')

    it 'should maintain the cursor position', =>
      expect(@textArea[0].selectionStart).toEqual(4)
