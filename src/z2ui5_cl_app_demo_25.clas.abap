CLASS z2ui5_cl_app_demo_25 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_input TYPE string.
    DATA mv_input_previous TYPE string.
    DATA mv_input_previous_set TYPE string.
    DATA mv_show_view TYPE string.

    DATA mv_event_backend TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_25 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    CASE client->get( )-event.

      WHEN 'BUTTON_ROUNDTRIP'.
        client->message_box_display( 'server-client roundtrip, method on_event of the abap controller was called' ).

      WHEN 'BUTTON_RESTART'.
        client->nav_app_call( NEW z2ui5_cl_app_demo_25( ) ).

      WHEN 'BUTTON_CHANGE_APP'.
        client->nav_app_call( NEW z2ui5_cl_app_demo_01( ) ).

      WHEN 'BUTTON_READ_PREVIOUS'.
        DATA(lo_previous_app) = CAST z2ui5_cl_app_demo_24( client->get_app( client->get( )-id_prev_app ) ).
        mv_input_previous = lo_previous_app->mv_input2.
        client->message_toast_display( `data of previous app read` ).

      WHEN 'SHOW_VIEW_MAIN'.
        mv_show_view = 'MAIN'.

      WHEN 'BACK_WITH_EVENT'.
        lo_previous_app = CAST z2ui5_cl_app_demo_24( client->get_app( client->get( )-id_prev_app_stack ) ).
        lo_previous_app->mv_backend_event = 'CALL_PREVIOUS_APP_INPUT_RETURN'.
        client->nav_app_leave( lo_previous_app ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

      WHEN OTHERS.

        CASE mv_event_backend.

          WHEN 'NEW_APP_EVENT'.
            client->message_box_display( 'new app called and event NEW_APP_EVENT raised' ).

        ENDCASE.

    ENDCASE.


    CASE mv_show_view.

      WHEN 'MAIN' OR ''.

        data(view) = Z2UI5_CL_XML_VIEW=>factory( client ).
        DATA(page) = view->shell(
            )->page(
                   title          = 'abap2UI5 - flow logic - APP 02'
                   navbuttonpress = client->_event( 'BACK' ) shownavbutton = abap_true
               )->header_content(
                   )->link( text = 'Demo'        target = '_blank' href = `https://twitter.com/abap2UI5/status/1640743794206228480`
                   )->link( text = 'Source_Code' target = '_blank' href = view->hlp_get_source_code_url( )
               )->get_parent( ).

        page->grid( 'L6 M12 S12' )->content( 'layout'

              )->simple_form( 'View: FIRST' )->content( 'form'

               )->label( 'Input set by previous app'
               )->input( mv_input_previous_set

               )->label( 'Data of previous app'
               )->input( mv_input_previous
               )->button( text = 'read' press = client->_event( 'BUTTON_READ_PREVIOUS' )

               )->label( 'Call previous app and show data of this app'
               )->input( client->_bind_edit( mv_input )
               )->button( text = 'back' press = client->_event( 'BACK_WITH_EVENT' ) ).

      WHEN 'SECOND'.

        view = Z2UI5_CL_XML_VIEW=>factory( client ).
        page = view->shell(
            )->page(
                    title          = 'abap2UI5 - flow logic - APP 02'
                    navbuttonpress = client->_event( val = 'BACK' check_view_destroy = abap_true ) shownavbutton = abap_true
                )->header_content(
                    )->link( text = 'Demo'        href = `https://twitter.com/abap2UI5/status/1640743794206228480`
                    )->link( text = 'Source_Code' href = view->hlp_get_source_code_url(  )
                )->get_parent( ).

        page->grid( 'L6 M12 S12' )->content( 'layout'
            )->simple_form( 'View: SECOND' )->content( 'form'
              )->label( 'Demo'
              )->button( text = 'leave to previous app' press = client->_event( 'BACK' )
              )->label( 'Demo'
              )->button( text = 'show view main' press = client->_event( 'SHOW_VIEW_MAIN' ) ).

    ENDCASE.

    client->view_display( view->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
