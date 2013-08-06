$(document).find('button[copy-to-clip="true"]').each () ->
	clip = new ZeroClipboard(this)
	clip.on( 'mousedown', (client) ->
		$(this).popover('show')
		setTimeout( (=> $(this).popover('destroy')), 800)
	)
