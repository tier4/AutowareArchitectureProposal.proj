#!/usr/bin/env bash

SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
source "$SCRIPT_DIR/common/helper_functions.sh"

# Define functions
function show_usage() {
  echo -e "Usage: create_product_release_tags.sh reference_version product_version
      [-h/--help] [-y/--yes] [--change-reference-repositories] [--delete]

    -h/--help:
      Show usage and exit.

    -y/--yes:
      Proceed without confirmation.

    --change-reference-repositories:
      Whether to create branches/tags in reference repositories.

    --delete:
      Whether to delete branches/tags. Please use this option when you mistook something.

    reference_version:
      The version to be used for reference release tags.
      The valid pattern is '^v([0-9]+)\.([0-9]+)\.([0-9]+)$'.

    product_version:
      The version to be used for product release tags.
      The valid pattern is '^v([0-9]+)\.([0-9]+)\.([0-9]+)$'.
    "
}

# Parse arguments
source "$SCRIPT_DIR/common/parse_common_args.sh"
reference_version="${args[0]}"
product_version="${args[1]}"

# Check args
if ! is_valid_reference_release_version "$reference_version"; then
  echo -e "\e[31mPlease input a valid reference release version as the 1st argument.\e[m"
  show_usage
  exit 1
fi

if ! is_valid_product_release_version "$product_version"; then
  echo -e "\e[31mPlease input a valid product release version as the 2nd argument.\e[m"
  show_usage
  exit 1
fi

# Check if using RC branch
if ! is_on_corresponding_rc_branch "$product_version"; then
  echo -e "\e[31mPlease checkout corresponding RC branch for $product_version.\e[m"
  exit 1
fi

# Run pre common tasks
source "$SCRIPT_DIR/common/pre_common_tasks.sh"

# Create tags in reference repositories
echo -e "\e[36mCreate tags in reference repositories\e[m"
for reference_repository in $(get_reference_repositories); do
  if [ "$flag_change_reference_repositories" ]; then
    create_tag "$reference_repository" "$reference_version" "$flag_delete"
  else
    checkout_branch_or_tag "$reference_repository" "$reference_version"
  fi
done

# Create tags in product repositories
echo -e "\e[36mCreate tags in product repositories\e[m"
for product_repository in $(get_product_repositories); do
  create_tag "$product_repository" "$product_version" "$flag_delete"
done

# Run post common tasks
if [ "$flag_delete" = "" ]; then
  source "$SCRIPT_DIR/common/post_common_tasks.sh"
fi

# Create tag in meta repository
create_tag "$(get_meta_repository)" "$product_version" "$flag_delete"