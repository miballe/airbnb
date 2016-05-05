import pandas as pd

session = pd.read_csv("sessions.csv")

grouped_type = session.groupby(by=["action_type", "user_id"])

# get a list of all the action_type, action_detail etc.
action_types = session.action_type.unique()[1:]

action_details = session.action_detail.unique()

action = session.action.unique()

users_uni = session.user_id.unique()

# For action_type

act_type = pd.DataFrame(index=users_uni, columns=action_types)

act_type["user_id"] = users_uni

act_type.fillna(value = 0, inplace=True)

for name, group in grouped_type:
       n = len(group)

       act_type[name[0]].ix[name[1]] = n

print(act_type.head())

act_type.to_csv("User_bag_of_action_type.csv", index=False)

# For action_detail

grouped_detail = session.groupby(by=["action_detail", "user_id"])

act_detail = pd.DataFrame(index=users_uni, columns=action_details)

act_detail["user_id"] = users_uni

act_detail.fillna(value = 0, inplace=True)

for name, group in grouped_detail:
	n = len(group)

	act_detail[name[0]].ix[name[1]] = n

print(act_detail.head())

act_detail.to_csv("User_bag_of_action_detail.csv", index=False)

# For action

grouped = session.groupby(by=["action", "user_id"])

actions = pd.DataFrame(index=users_uni, columns=action)

actions["user_id"] = users_uni

actions.fillna(value = 0, inplace=True)

for name, group in grouped:
	n = len(group)

	actions[name[0]].ix[name[1]] = n

print(actions.head())

actions.to_csv("User_bag_of_actions.csv", index=False)

merged = act_type.merge(act_detail, right_on="user_id", left_on="user_id")


# cols = ['user_id', 'view_search_results', 'wishlist_content_update',
#        'similar_listings', 'change_trip_characteristics', 'p3',
#        'header_userpic', 'contact_host', 'message_post', '-unknown-',
#        'dashboard', 'create_user', 'confirm_email_link',
#        'user_profile_content_update', 'user_profile', 'pending', 'p5',
#        'create_phone_numbers', 'cancellation_policies', 'user_wishlists',
#        'change_contact_host_dates', 'wishlist', 'message_thread',
#        'request_new_confirm_email', 'send_message', 'your_trips',
#        'login_page', 'login', 'login_modal', 'toggle_archived_thread',
#        'p1', 'profile_verifications', 'edit_profile', 'oauth_login',
#        'post_checkout_action', 'account_notification_settings',
#        'update_user_profile', 'oauth_response', 'signup_modal',
#        'signup_login_page', 'at_checkpoint', 'manage_listing',
#        'create_listing', 'your_listings', 'profile_references',
#        'list_your_space', 'popular_wishlists', 'listing_reviews_page',
#        'apply_coupon', 'user_tax_forms', 'account_payout_preferences',
#        'guest_itinerary', 'guest_receipt', 'account_privacy_settings',
#        'lookup_message_thread', 'friends_wishlists', 'host_guarantee',
#        'delete_phone_numbers', 'account_transaction_history',
#        'set_password', 'guest_cancellation', 'change_or_alter',
#        'your_reservations', 'terms_and_privacy', 'airbnb_picks_wishlists',
#        'toggle_starred_thread', 'email_wishlist', 'email_wishlist_button',
#        'wishlist_note', 'calculate_worth', 'place_worth',
#        'change_password', 'alteration_field', 'previous_trips',
#        'update_listing', 'update_listing_description', 'user_reviews',
#        'update_user', 'notifications', 'user_social_connections',
#        'unavailable_dates', 'reservations', 'listing_reviews',
#        'user_listings', 'signup', 'message_inbox', 'trip_availability',
#        'payment_instruments', 'admin_templates', 'host_home',
#        'translations', 'forgot_password', 'homepage',
#        'remove_dashboard_alert', 'user_friend_recommendations',
#        'confirm_email', 'host_respond', 'booking',
#        'respond_to_alteration_request', 'alteration_request',
#        'create_alteration_request', 'delete_listing', 'set_password_page',
#        'delete_listing_description', 'translate_listing_reviews',
#        'book_it', 'instant_book', 'request_to_book', 'complete_booking',
#        'change_availability', 'special_offer_field',
#        'listing_recommendations', 'view_listing', 'listing_descriptions',
#        'user_languages', 'p4', 'message_to_host_focus',
#        'cancellation_policy_click', 'message_to_host_change',
#        'read_policy_click', 'phone_verification_success',
#        'p4_refund_policy_terms', 'apply_coupon_error',
#        'apply_coupon_click', 'coupon_field_focus', 'coupon_code_click',
#        'p4_terms', 'apply_coupon_click_success', 'tos_2014',
#        'view_reservations', 'view_locations', 'modify_users',
#        'view_security_checks', 'phone_numbers', 'profile_reviews',
#        'modify_reservations', 'view_resolutions',
#        'account_payment_methods', 'create_payment_instrument',
#        'set_default_payment_instrument', 'delete_payment_instrument',
#        'photos', 'click_reviews', 'move_map', 'share',
#        'cancellation_policy', 'click_about_host', 'click_amenities',
#        'host_refund_guest', 'host_respond_page', 'view_user_real_names',
#        'view_identity_verifications', 'view_ghosting_reasons',
#        'view_ghostings', 'host_standard_suspension',
#        'deactivate_user_account']

# df_detail = pd.read_csv("User_bag_of_action_detail", columns = cols)

