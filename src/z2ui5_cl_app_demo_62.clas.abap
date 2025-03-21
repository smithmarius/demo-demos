CLASS z2ui5_cl_app_demo_62 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF screen,
        check_is_active TYPE abap_bool,
        colour          TYPE string,
      END OF screen.

    DATA check_initialized TYPE abap_bool.
    DATA client TYPE REF TO z2ui5_if_client.

  PROTECTED SECTION.

    METHODS z2ui5_on_rendering
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_62 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      SELECT SINGLE FROM z2ui5_t_demo_01
        FIELDS *
        WHERE name = 'TEST01'
        INTO @DATA(ls_data).

      IF sy-subrc = 0.
        SELECT SINGLE FROM z2ui5_t_draft
         FIELDS *
        WHERE uuid = @ls_data-uuid
       INTO @DATA(ls_draft).

        IF sy-subrc = 0.
          client->nav_app_leave( client->get_app( ls_draft-uuid ) ).
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    z2ui5_on_event( client ).
    z2ui5_on_rendering( client ).

    MODIFY z2ui5_t_demo_01 FROM @( VALUE #( uuid = client->get( )-id name = 'TEST01' ) ).
    COMMIT WORK.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

*      WHEN 'BUTTON_SEND'.
*        client->message_box_display( 'success - values send to the server' ).
*      WHEN 'BUTTON_CLEAR'.
*        CLEAR screen.
*        client->message_toast_display( 'View initialized' ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_on_rendering.

    DATA(page) = z2ui5_cl_xml_view=>factory( client )->shell(
         )->page(
            title          = 'abap2UI5 - Start app with values Demo'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true ).

    page->header_content(
             )->link( text = 'Demo'    target = '_blank'    href = `https://twitter.com/abap2UI5/status/1628701535222865922`
             )->link( text = 'Source_Code'  target = '_blank' href = page->hlp_get_source_code_url(  )
         )->get_parent( ).

    DATA(grid) = page->grid( 'L6 M12 S12'
        )->content( 'layout' ).

    grid->simple_form( editable = abap_true title = 'Input'
        )->content( 'form'
*            )->button( press = client->_event( `test` )
            )->label( 'Make an input here and restart the app'
            )->input(
                    value           = client->_bind_edit( screen-colour )
                    placeholder     = 'fill in your favorite colour'  ).

    client->view_display( page->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
