$( ->
  $(document).find('button[com_add="true"]').click( ->
    i = $(this).attr("val")
    $.ajax({
      url: "com_add"
      type: "POST"
      data: { d: {
        index: i }}
      error: (XMLHttpRequest, textStatus, errorThrown) ->
        alert("wyjebalo mnie "+textStatus+" "+errorThrown+" "+XMLHttpRequest)
      success: (data) ->
        $('td.comment_'+data.index+'').replaceWith(data.to_send)
    })
  )

  $(document).find('button[com_show="true"]').click( ->
    el = $('td.comment_'+$(this).attr("val") + ' > span')
    if el.is(':visible')
      el.hide()
      $(this).html 'Show'
    else
      el.show()
      $(this).html 'Hide'
  )

#  $(document).find('button[com_hide="true"]').click( ->
#    i = $(this).attr("val")
#    c = $(this).attr("com")
#    button = $(this)
#    $.ajax({
#      url: "com_hide"
#      type: "POST"
#      data: { d: {
#        index: i
#        com: c }}
#      error: (XMLHttpRequest, textStatus, errorThrown) ->
#        alert("wyjebalo mnie "+textStatus+" "+errorThrown+" "+XMLHttpRequest)
#      success: (data) ->
#        $('td.comment_'+data.index+'').replaceWith(data.to_send)
#        button.toggle()
#    })
#  )
)