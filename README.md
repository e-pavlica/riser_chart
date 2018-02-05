GMCLA Riser Chart Generator
===========================

This is a little Ruby script I created to generate riser charts for the Gay Men's Chorus of Los Angeles. It requires Ruby 2.3 or newer, and will likely not run on a Windows-based machine (Mac or Linux should work).

For each show, create a new directory for the script to generate chart into.

This script depends on two files sourced from Chorus Connection. The first is found in the riser charts section;  create a new riser chart, then right-click on the page choose 'Inspect Element'. Click on the 'Network' tab, and reload the page. Look for `riser_chart.json` and save this file to your show directory.

The second file is the the membership directory info... keep your inspector open, and click on the 'Members' tab in Chrous Connection. You should see a `chorus_members.json` file in the inspector's network tab... save this to your show directory as well.

Finally, use this script:

- Download this repo: `git clone https://github.com/xicreative/riser_chart.git` (or download the zip file from the github page)
- `cd` into the repo directory and run `ruby create_riser_chart.rb`
- When prompted, enter the relative path to your show directory.

If everything goes well, a riser chart will be generated in a dated sub-directory of your show folder.


### Notes:

- This assumes you'll be using all 8 riser wedges.
- The default section order is B1, B2, T1, T2. You can change this by editing the `SECTIONS` constant in `riser_chart.rb`
- Check out the `upper_lower_split` branch if you need something like B1H, B2H, T1H, T2H, B1L, B2L, T1L, T2L

