{Templates} = require '../app/coffee/templates'

describe 'Templates', ->
  describe '.get', ->
    it 'throws an error if the path is not a string', ->
      expect(-> Templates.get()).to.throw(Error)
      expect(-> Templates.get(5, {})).to.throw(Error)
      expect(-> Templates.get('', {})).to.throw(Error)

    it 'returs the expected template .start', ->
      expectedTemplate = """
      i {
      \tbackground-image: url('alberto.png');
      \tdisplay: inline-block;
      }

      """

      template = Templates.get('css.start', {fileName: 'alberto'})

      expect(template).to.be.equal(expectedTemplate)

    it 'returs the expected template .block', ->
      expectedTemplate = """
      i.sara {
      \tbackground-position: 0 -30px;
      \theight: 31px;
      \twidth: 32px;
      }

      """

      context =
        name: 'sara'
        left: 0
        top: 30
        height: 31
        width: 32

      template = Templates.get('css.block', context)

      expect(template).to.be.equal(expectedTemplate)

    it 'returns a css template', ->
      expectedTemplate = """
      i {
      \tbackground-image: url('cssspritepro.png');
      \tdisplay: inline-block;
      }
      i.trash {
      \tbackground-position: 0 0;
      \theight: 30px;
      \twidth: 30px;
      }
      i.trash:hover {
      \tbackground-position: -30px 0;
      \theight: 30px;
      \twidth: 30px;
      }

      """

      context =
        fileName: 'cssspritepro'

        icon1:
          name: 'trash'
          left: 0
          top: 0
          height: 30
          width: 30

        icon2:
          name: 'trash:hover'
          left: 30
          top: 0
          height: 30
          width: 30

      buffer = []

      buffer.push Templates.get('css.start', context)
      buffer.push Templates.get('css.block', context.icon1)
      buffer.push Templates.get('css.block', context.icon2)
      buffer.push Templates.get('css.end')

      template = buffer.join('')

      expect(template).to.be.equal(expectedTemplate)

    it 'returns a scss template', ->
      expectedTemplate = """
      i {
      \tbackground-image: url('cssspritepro.png');
      \tdisplay: inline-block;

      \t&.trash {
      \t\tbackground-position: 0 0;
      \t\theight: 30px;
      \t\twidth: 30px;
      \t}
      \t&.trash:hover {
      \t\tbackground-position: -30px 0;
      \t\theight: 30px;
      \t\twidth: 30px;
      \t}
      }
      """

      context =
        fileName: 'cssspritepro'

        icon1:
          name: 'trash'
          left: 0
          top: 0
          height: 30
          width: 30

        icon2:
          name: 'trash:hover'
          left: 30
          top: 0
          height: 30
          width: 30

      buffer = []

      buffer.push Templates.get('scss.start', context)
      buffer.push Templates.get('scss.block', context.icon1)
      buffer.push Templates.get('scss.block', context.icon2)
      buffer.push Templates.get('scss.end')

      template = buffer.join('')

      expect(template).to.be.equal(expectedTemplate)

    it 'returns a sass template', ->
      expectedTemplate = """
      i
      \tbackground-image: url('cssspritepro.png')
      \tdisplay: inline-block

      \t&.trash
      \t\tbackground-position: 0 0
      \t\theight: 30px
      \t\twidth: 30px

      \t&.trash:hover
      \t\tbackground-position: -30px 0
      \t\theight: 30px
      \t\twidth: 30px


      """

      context =
        fileName: 'cssspritepro'

        icon1:
          name: 'trash'
          left: 0
          top: 0
          height: 30
          width: 30

        icon2:
          name: 'trash:hover'
          left: 30
          top: 0
          height: 30
          width: 30

      buffer = []

      buffer.push Templates.get('sass.start', context)
      buffer.push Templates.get('sass.block', context.icon1)
      buffer.push Templates.get('sass.block', context.icon2)
      buffer.push Templates.get('sass.end')

      template = buffer.join('')

      expect(template).to.be.equal(expectedTemplate)
