CLASS z2ui5_cl_app_demo_35 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_type TYPE string.
    DATA mv_path TYPE string.
    DATA mv_editor TYPE string.
    DATA mv_check_editable TYPE abap_bool.
    DATA check_initialized TYPE abap_bool.

    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_35 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      mv_path = '../../demo/text'.
      mv_type = 'plain_text'.
      view_display( ).
    ENDIF.

    CASE client->get( )-event.

      WHEN 'DB_LOAD'.

        mv_editor = COND #(
            WHEN mv_path CS 'abap' THEN lcl_mime_api=>read_abap( )
            WHEN mv_path CS 'json' THEN lcl_mime_api=>read_json( )
            WHEN mv_path CS 'yaml' THEN lcl_mime_api=>read_yaml( )
            WHEN mv_path CS 'text' THEN lcl_mime_api=>read_text( )
            WHEN mv_path CS 'js'   THEN lcl_mime_api=>read_js( )
            ).
        client->message_toast_display( 'Download successfull' ).

      WHEN 'DB_SAVE'.
        lcl_mime_api=>save_data( ).
        client->message_box_display( text = 'Upload successfull. File saved!' type = 'success' ).
      WHEN 'EDIT'.
        mv_check_editable = xsdbool( mv_check_editable = abap_false ).
      WHEN 'CLEAR'.
        mv_editor = ``.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).
    ENDCASE.


  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( client ).
    DATA(page) = view->shell( )->page(
    title = 'abap2UI5 - MIME Editor'
    navbuttonpress = client->_event( 'BACK' )
    shownavbutton = abap_true
            )->header_content(
                )->link( text = 'Demo'        target = '_blank' href = 'https://twitter.com/abap2UI5/status/1631562906570575875'
                )->link( text = 'Source_Code' target = '_blank' href = view->hlp_get_source_code_url( )
        )->get_parent( ).

    DATA(grid) = page->grid( 'L7 M12 S12' )->content( 'layout' ).

    grid->simple_form( title = 'File' editable = abap_true )->content( 'form'
         )->label( 'path'
         )->input( client->_bind_edit( mv_path )
         )->label( 'Option'
         )->input(
                value           = client->_bind_edit( mv_type )
                suggestionitems = client->_bind( lcl_mime_api=>get_editor_type( ) ) )->get(
            )->suggestion_items(
                )->list_item( text = '{NAME}' additionaltext = '{VALUE}'
         )->get_parent( )->get_parent(
         )->button(
                text  = 'Download'
                press = client->_event( 'DB_LOAD' )
                icon  = 'sap-icon://download-from-cloud' ).

    grid = page->grid( 'L12 M12 S12' )->content( 'layout' ).

    grid->simple_form( 'Editor' )->content( 'form'
            )->scroll_container( '75%'
                )->code_editor(
                    type  = mv_type
                    editable = mv_check_editable
                    value = client->_bind( mv_editor ) ).

    page->footer( )->overflow_toolbar(
        )->button(
             text = 'Clear'
             press = client->_event( 'CLEAR' )
             icon  = 'sap-icon://delete'
        )->toolbar_spacer(
        )->button(
            text  = 'Edit'
            press = client->_event( 'EDIT' )
            icon = 'sap-icon://edit'
        )->button(
            text  = 'Upload'
            press = client->_event( 'DB_SAVE' )
            type  = 'Emphasized'
            icon = 'sap-icon://upload-to-cloud'
            enabled = xsdbool( mv_editor IS NOT INITIAL ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
