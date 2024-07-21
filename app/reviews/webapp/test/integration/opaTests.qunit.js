sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'reviews/test/integration/FirstJourney',
		'reviews/test/integration/pages/ReviewsList',
		'reviews/test/integration/pages/ReviewsObjectPage'
    ],
    function(JourneyRunner, opaJourney, ReviewsList, ReviewsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('reviews') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheReviewsList: ReviewsList,
					onTheReviewsObjectPage: ReviewsObjectPage
                }
            },
            opaJourney.run
        );
    }
);