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

# OK
  $(document).find('button[com_show="true"]').click( ->
    el = $('td.comment_'+$(this).attr("val") + ' > div')
    edit = $('td.comment_'+$(this).attr("val") + ' > button[com_edit="true"]')
    del = $('td.comment_'+$(this).attr("val") + ' > button[com_del="true"]')
    if el.is(':visible')
      el.hide()
      edit.hide()
      del.hide()
      $(this).html 'Show'
    else
      el.show()
      edit.show()
      del.show()
      $(this).html 'Hide'
  )
#
# OK
  $(document).find('button[com_edit="true"]').click( ->
    i = $(this).attr("index")
    c = $(this).attr("com")
    d = $(this).attr("date")
    modal = $('td.comment_'+i+'').find('#myModal_'+i)
    title = modal.find('.modal-title')
    text = modal.find('#textarea')
    modal.on('show.bs.modal', ->
      title.html d
      text.val c

    ).modal('toggle')
  )
#
# OK
  $(document).find('button[com_edit_save="true"]').click( ->
    i = $(this).attr("index")
    modal = $('td.comment_'+i+'').find('#myModal_'+i)
    title = modal.find('.modal-title').text()
    text = modal.find('#textarea').val()
    el = $('td.comment_'+i+ ' > div')
    $.ajax({
      url: "com_edit_save"
      type: "PUT"
      data: { d: {
        date: title
        com: text
        }}
      error: (XMLHttpRequest, textStatus, errorThrown) ->
        alert("wyjebalo mnie "+textStatus+" "+errorThrown+" "+XMLHttpRequest)
      success: (data) ->
        el.html data.to_send
        modal.modal('hide')
    })
  )
#

  # OK
  $(document).find('button[com_del="true"]').click( ->
    i = $(this).attr("index")
    d = $(this).attr("date")
    $.ajax({
      url: "com_del"
      type: "DELETE"
      data: { d: {
        date: d
        index: i
      }}
      error: (XMLHttpRequest, textStatus, errorThrown) ->
        alert("wyjebalo mnie "+textStatus+" "+errorThrown+" "+XMLHttpRequest)
      success: (data) ->
        alert "usunieto"
    })
  )
#

)