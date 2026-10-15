# Automation entry

Recommended opening sequence:

1. `js-reverse_new_page` or `js-reverse_navigate_page` open the page
2. `js-reverse_list_network_requests` View recent requests
3. `js-reverse_get_request_initiator` Find the call stack
4. `js-reverse_list_scripts` creates script range
5. `js-reverse_search_in_sources` search request path, parameter name, function name
6. `js-reverse_break_on_xhr` or `js-reverse_set_breakpoint_on_text` if necessary

By default, don’t guess how to fix `window`, `document`, `navigator` right from the start.