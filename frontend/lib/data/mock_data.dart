import '../models/models.dart';

class MockData {
  // Current logged in user
  static final CatUser currentUser = CatUser(
    id: 'user_mochi',
    username: 'mochi_the_ragdoll',
    displayName: 'Mochi The Ragdoll',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDgHq4gqaix1Z8C7wnrG9dw8dQcSa6fwprjccleQOkLGHiHDm_S23rtMaEWSa93Wgjp2ubKkH2fMNZKfI_udBUhr2bUkoz5rb49FiL0FlMYlg_f_ECWWkJb4VYQKqgGmIYkn7mZr0eqo-es1dmY3QvgM7Xd4jiKHlMBmP1pH4bJTNFUkJh0lbGFXhUXK6KsZPKrCpMMFU9l0ZB65hPiJWdCMMStFnaTeUM7_sSSEQbTxXiqTOsFryu3mw',
    bio:
        'Fluffy cloud living in Tokyo.\nSunbeam connoisseur & treat enthusiast.\nAmbassador for @whiskerbox • Meow vibes only',
    category: 'Ragdoll • Cat Creator',
    website: 'mochi.instacat.pet',
    isVerified: true,
    postsCount: 54,
    followersCount: '12.4k',
    followingCount: 180,
  );

  // Other community cat users
  static const CatUser biscuitPaw = CatUser(
    id: 'user_biscuit',
    username: 'biscuit_paw',
    displayName: 'Biscuit The Tabby',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBJt8VaXk4Zgd7GNmfMmhFi93IGwCCQunJPX2vl6Vp557bzBO6SytIxggzAeIuWejn11ioHu1g2bCYQ14GOXtwB5kNsAgngGZorc23oWdMM02l_A7uZzkTZa5yatmhwc-Ky4K1flsRIZUtuUYraoKs7LOclw9ii1On5wt4nqBFrRa-GtaeB90CZHDk4w7Vffixu6VL8RN8CT6Zkk0RroXauK3mjDPimS05Al_lN5uZgAvHzHXrmC9b3MQ',
    isVerified: false,
  );

  static const CatUser miloTheScottish = CatUser(
    id: 'user_milo',
    username: 'milo_the_scottish',
    displayName: 'Milo Scottish Fold',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBKP0-y--DPd8PMpMEa-uUVkQU7UHOqOyRifF9Nmou5OG9q8FBA63lyB0VhH0W3JOGj3n6BURGOMmNWvdjeoDSZ1RxfnqQ730vb-LBcX1-S5cb9j0ejUXPSTgkbjxvuj7ZzquS9HsIjzd4XQNr2h-ws7jSSQELzF1vPZE6k2tmzasn4YhII-DMdXMG6aTxDoc3FBUn8LjmAxiORwdjFT0eVKujsMEHGqPZkHM1Y7sQgomINBtKydaHeHw',
    isVerified: true,
  );

  static const CatUser lunaCalico = CatUser(
    id: 'user_luna',
    username: 'luna_calico',
    displayName: 'Luna Queen of Boxes',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAuM81muV4-auVviYV8d2mkDXrgf-2maGX995fexQdDsQY6s8DjE7NERzjWhOCNDlLdcSk4lZlep4igpnWLITMdxf1cTxWNJdUpVTZ9BO8cjRAqyQRnB2JFdzmwoBeTOtoGkrFmDAhtdIU_rvs6uzuEyWpCYeewLooyKYFJ7QZL2FdWLCxHPSJUpw9mf_8BJzyHzsSEbCZFRlIySz5sFU-WAdiodlHUdXT6vPBxSe_F3BE6m3ThmN1AQw',
    isVerified: false,
  );

  static const CatUser oliverWhiskers = CatUser(
    id: 'user_oliver',
    username: 'oliver_whiskers',
    displayName: 'Sir Oliver Whiskers',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCNg0tHEFsrWsnyY89LdFF6ZstaK2tWj4YTcigVrGwKy8-ptnpkw393gGpwfdeH6oLmW5L4Np7eG69xY8puBmM7PhD8VIJV_5P_hGP8H0-fddKNiM9_t80xMUOCQa9EzEmw34w3jMI3Vu930XOU6dQA8N2ra3ii9N0lgwZQc-7I75yIMjigZyfW5itqOUmH9CXTirezA6upq77BUoUTqxRd1nutkMR2cjysYYSiIl-2BaxhUoeAL_fKrQ',
    isVerified: true,
  );

  static const CatUser churuLover = CatUser(
    id: 'user_churu',
    username: 'churu_lover',
    displayName: 'Tuxedo Boy',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDuZC54QsSlf6TR5AmkVTxPPaPakSAEob28KF4Z9Sk6by3MWxmCCOnXvr5afvIyR5oc0fbD-xFwRZ4Y-12k0yMehigMxXe1yrmDiStMkYGuie6Pe9fl7_1XsyfUl5DcD-XercsiwBgTlLotyd0dc65qrmA5i4xc2D2VxshAkjsTm-Pq77eNnJbpJRWrVn5VZxhEffYe67RGjlw1XDe6Gbr9EiH_voz3HRMbdStl-tQhOAYdTi0keMBhZg',
    isVerified: false,
  );

  // Stories list
  static final List<Story> stories = [
    Story(
      id: 'story_self',
      user: currentUser,
      isCurrentUser: true,
      isViewed: false,
    ),
    const Story(
      id: 'story_milo',
      user: miloTheScottish,
      isViewed: false,
    ),
    const Story(
      id: 'story_luna',
      user: lunaCalico,
      isViewed: false,
    ),
    const Story(
      id: 'story_oliver',
      user: oliverWhiskers,
      isViewed: false,
    ),
    const Story(
      id: 'story_churu',
      user: churuLover,
      isViewed: true,
    ),
  ];

  // Feed Posts
  static final List<Post> feedPosts = [
    Post(
      id: 'post_1',
      user: currentUser,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBRLzRS5H3IvL4LT7u_8fAIa2FuqGwiMYB5gM1Qj1dh3Xei5W_oIxRGRvp7sKMrb_6I0LxGyyuky8d8SQqn7N_5ltd7iEAPqj2_S12qSN7Wc6BeVQqV1J-gw_MeEMk_7cNXo3u24OqhxVJB-vITWacY_zfhEpI-UKPmguwAa7x9lVjUlo8Ffk72pBbzIV1FxpN9d5JQc5XsEcgB35RqOIUCoSr0DcCjH_8771JRtMUQl-y44TKYDX4JQA',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDDBl5kjm2hikukZvpcCAECB9j2PuHg9ayo5nPWLPMDarkwCEdVJI27ZNxN9q2qhlJbvED8luvPF16XpkxDJS-krucHuwooGk5Y2DW775Wi9jpD7HiSias35hrPAraQ9Qegpf_vGtPrHP4pvXVERjb-H5Guvvk3qx5DKcK1Ddi4BvReW--kuK-71aB6eIk2MabHuvnOJruodO_GVqgGefOorT8ciGLrzNFbIPNkSiEuDeQzMIQTfAyXoA',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCI8o48Vm1oTkRdHXsVLF3aGcjYKfXQx8j-9oAwavwNktRfsn4RN7nQeggJBMaFulUSizPIqVrzISz0WaP6-RieYHrA7m7Z3BC5IAS9lJVa0Px39H3bniWpa4qZnF7yOpxE0NIpos3l07irEn0BUlC8wGfIKHAXR-yxbXitQDWM_Q6TRH7zbRL63GZ1ZvmowhyO9MKE3c_50M5r3gLjDzox-RqPdzFC2kEahubx3j-Dg67GCunJP4Hxlw',
      ],
      caption:
          'Enjoying the afternoon sunbeam on my favorite pillow. #catlife #ragdoll',
      likesCount: 1428,
      commentsCount: 84,
      location: 'Tokyo, Japan',
      timestamp: '2 hours ago',
      isLiked: true,
      isSaved: false,
    ),
    Post(
      id: 'post_2',
      user: biscuitPaw,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBJt8VaXk4Zgd7GNmfMmhFi93IGwCCQunJPX2vl6Vp557bzBO6SytIxggzAeIuWejn11ioHu1g2bCYQ14GOXtwB5kNsAgngGZorc23oWdMM02l_A7uZzkTZa5yatmhwc-Ky4K1flsRIZUtuUYraoKs7LOclw9ii1On5wt4nqBFrRa-GtaeB90CZHDk4w7Vffixu6VL8RN8CT6Zkk0RroXauK3mjDPimS05Al_lN5uZgAvHzHXrmC9b3MQ',
      ],
      caption:
          'Mastered the art of knocking over water cups at 3 AM. #mischief #caturday #treats',
      likesCount: 852,
      commentsCount: 32,
      location: 'Osaka, Japan',
      timestamp: '5 hours ago',
      isLiked: false,
      isSaved: true,
    ),
    Post(
      id: 'post_3',
      user: miloTheScottish,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBKP0-y--DPd8PMpMEa-uUVkQU7UHOqOyRifF9Nmou5OG9q8FBA63lyB0VhH0W3JOGj3n6BURGOMmNWvdjeoDSZ1RxfnqQ730vb-LBcX1-S5cb9j0ejUXPSTgkbjxvuj7ZzquS9HsIjzd4XQNr2h-ws7jSSQELzF1vPZE6k2tmzasn4YhII-DMdXMG6aTxDoc3FBUn8LjmAxiORwdjFT0eVKujsMEHGqPZkHM1Y7sQgomINBtKydaHeHw',
      ],
      caption: 'Does this box make my ears look small? #scottishfold #catsinboxes',
      likesCount: 2310,
      commentsCount: 115,
      location: 'Seoul, South Korea',
      timestamp: '8 hours ago',
      isLiked: false,
      isSaved: false,
    ),
  ];

  // Current user's own published posts for profile grid
  static final List<Post> currentUserPosts = [
    feedPosts[0], // post_1
    Post(
      id: 'post_m2',
      user: currentUser,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD_GWNiPrv6ef4Zg1hl57wslNmd_9SxjRtsOAhhRMS3ZElZf5KT8MiAZDgvNiO2Sn6kT5bS24xHLgkbhPEEVF4ri87Y48FjSAxOcPmNp7He80fCfKD7JgrC9twIwkoXLu1QGOt1UiThGXnB7cxW23PUetH_yMvcamiSOxE-YPi2MiILWGfTr9MveQ6jO86AeDvsBFGb0Ta5P9qb1HiG1sV4lfSzUwv6H-BJdeHVYIVpHz-dVVsi4WY4Lw',
      ],
      caption: 'Golden hour purrs are the best kind of purrs. #dailyviral #ragdoll',
      likesCount: 942,
      commentsCount: 45,
      location: 'Tokyo, Japan',
      timestamp: '1 day ago',
      isLiked: false,
    ),
    Post(
      id: 'post_m3',
      user: currentUser,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB49A1ML0Ok0tP0-bQom7LQzwuOMr4u9KFWaNcrE8lWjg3zYtFXQ26GpOgn-gfZKAc_RabLxZvOt2mnGNpHDhCG5x_9UekW9Y9mBCLUNggn3rjb3UJJs7KygRXQvtA_J24vdUKdXwI6gnRjPsYJgiJfIpXFct1SMn6i-2Lfec09dIp-6xLdV8jTeSqoLV6C9NcMA73Bt7_v0CaLZAUVACtIg0cgHmrA0_aO8Ne9Wirr0_QHSeQw1APrCw',
      ],
      caption: 'Looking cool with my shades on. #swagcat #instacat',
      likesCount: 1820,
      commentsCount: 92,
      location: 'Shibuya, Tokyo',
      timestamp: '3 days ago',
      isLiked: true,
    ),
    Post(
      id: 'post_m4',
      user: currentUser,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDqvlv_Q1vj1FDF9B1SH10P8obnajjqh4-xicqYNnfopI7q-PIHWTVT5pkPj3WEq1kocGVKD3_nKfbZjY-hShlkoefPpAF22lKGqBvgxMTVtGDT6tXc1jmwdqFwhl-e2tTXJAUdCU_CUKfyu6nvajd-bOjCe5SM3pjbwh8V4p9OIhhHiQCAMf0fdCdUaf2E16qGLnF8ASCP-j6wpNUyB8VeiYHwFnDCDZNLdw7ZEGHUArBhedqR4WiG7g',
      ],
      caption: 'Just observing the birds outside the window. #windowwatcher',
      likesCount: 654,
      commentsCount: 28,
      location: 'Tokyo, Japan',
      timestamp: '5 days ago',
      isLiked: false,
    ),
    Post(
      id: 'post_m5',
      user: currentUser,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAlfFPNSwtQNnj_tZ0XqC3HaLHCMBsfWek2hvKjBPL2IQOYeIYcU9oz94ubOXuyL7LA1slKTUgvQBMtPtb5DPqACfwsJnzDuGC6WPmKIywHE1Y41oWShx_TtzFALbslhuCB72xBGeP1ev0l0ysbHFLtE--HSY6AEg8WTNMhdh7CmyRgHYj32uLvAqnKhZnajCJbLMz4UqdNvUGoANqxtCg3ZSOpVbrWB_-HBjMVt_gOiqMtP9v6U-I3uA',
      ],
      caption: 'Playtime with the woolen yarn ball! #catplay #kittenvibes',
      likesCount: 2110,
      commentsCount: 104,
      location: 'Tokyo, Japan',
      timestamp: '1 week ago',
      isLiked: true,
    ),
    Post(
      id: 'post_m6',
      user: currentUser,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBr_cpvQTDpVyvAcHfJUaLwJ7iRJzucQth5zyU63zaMrT6bqp9vwjowYL9QC5JPICqLP31Ryams9nEcr-pHvi3hTS3wxM-T7dAm2eT99X6dujNwczSUUAvmoIoWPpAd65_d8aVXqw9V5ZqVhmF4jF3d1hFxr4Td5Dk_7SVO9dal15f97o1OGhtgObXZUp40CjWaqb6yOHQEx7x81gJawtn4vwmg2IAXuO2fb_d99SQy3alqR-4ij1NVNg',
      ],
      caption: 'Look into my eyes and give me treats! #churrotreats #ragdoll',
      likesCount: 3420,
      commentsCount: 148,
      location: 'Tokyo, Japan',
      timestamp: '2 weeks ago',
      isLiked: false,
    ),
  ];

  // Comments for Post 1
  static final List<Comment> postComments = [
    Comment(
      id: 'comment_1',
      user: biscuitPaw,
      text: 'The comfiest loaf ever! Need to try that pillow.',
      timestamp: '1h ago',
      likesCount: 12,
      isLiked: true,
      replies: [
        Comment(
          id: 'comment_1_reply_1',
          user: currentUser,
          text: '@biscuit_paw Highly recommended! It has maximum purr resonance.',
          timestamp: '45m ago',
          likesCount: 5,
        ),
      ],
    ),
    Comment(
      id: 'comment_2',
      user: lunaCalico,
      text: 'Such beautiful blue eyes Mochi!',
      timestamp: '1h ago',
      likesCount: 8,
      isLiked: false,
    ),
    Comment(
      id: 'comment_3',
      user: oliverWhiskers,
      text: 'Splendid afternoon leisure, good sir.',
      timestamp: '30m ago',
      likesCount: 3,
      isLiked: false,
    ),
  ];

  // Story Highlights for Profile
  static const List<StoryHighlight> profileHighlights = [
    StoryHighlight(
      id: 'hl_new',
      title: 'New',
      coverImageUrl: '',
      isNew: true,
    ),
    StoryHighlight(
      id: 'hl_play',
      title: 'Playtime',
      coverImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD-cnCZFq5ROl3D2_Np_9NxvzjfsVUmXeiWd-Eied7ZBHeyWvRCE8wjUYW-QiAyBNXY0tDJwQPjhXKdWKnwQmhNoAeFMcfyyKmtN-Mk6NY5uM6VB333A7865gHB4OJLPBLgg8b6g6IjP0KUFPa06rfZpj7rDUWv1ErbHk0DEg5cnL2M06I5Rh7gshFQrNjTchqo5iYc7Po3Nbig5ZakSVUnC66WQ7AYbv14pHH3qsLzdDihpL1pi0xL-w',
    ),
    StoryHighlight(
      id: 'hl_treats',
      title: 'Treats',
      coverImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBRLzRS5H3IvL4LT7u_8fAIa2FuqGwiMYB5gM1Qj1dh3Xei5W_oIxRGRvp7sKMrb_6I0LxGyyuky8d8SQqn7N_5ltd7iEAPqj2_S12qSN7Wc6BeVQqV1J-gw_MeEMk_7cNXo3u24OqhxVJB-vITWacY_zfhEpI-UKPmguwAa7x9lVjUlo8Ffk72pBbzIV1FxpN9d5JQc5XsEcgB35RqOIUCoSr0DcCjH_8771JRtMUQl-y44TKYDX4JQA',
    ),
    StoryHighlight(
      id: 'hl_naps',
      title: 'Naps',
      coverImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XD-x0dfUjXw3MIH4Lhlyk6wMnHcQp-CBshOZ3azaTzmv0uS67O_9nIHwDGpP7lRmeFng2pWrK1mMwbMXMrGPi4PvSbqLIOCZnDBBbCRYzXuVkXH6NBAy19G-G1Cn3Wi-EAQUnaetj2Un35INsvDzibHUVTFn22q0uArSDNfmqjtFOijKJb2d3YQLmrCGC-FPdw7IQgqzgAVUPjnX8ISOjnzIW154VDqYeJmuKM9mzpg6272nT3s8-Q',
    ),
    StoryHighlight(
      id: 'hl_ootd',
      title: 'OOTD',
      coverImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB49A1ML0Ok0tP0-bQom7LQzwuOMr4u9KFWaNcrE8lWjg3zYtFXQ26GpOgn-gfZKAc_RabLxZvOt2mnGNpHDhCG5x_9UekW9Y9mBCLUNggn3rjb3UJJs7KygRXQvtA_J24vdUKdXwI6gnRjPsYJgiJfIpXFct1SMn6i-2Lfec09dIp-6xLdV8jTeSqoLV6C9NcMA73Bt7_v0CaLZAUVACtIg0cgHmrA0_aO8Ne9Wirr0_QHSeQw1APrCw',
    ),
  ];

  // Explore Items
  static const List<String> exploreImages = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD_GWNiPrv6ef4Zg1hl57wslNmd_9SxjRtsOAhhRMS3ZElZf5KT8MiAZDgvNiO2Sn6kT5bS24xHLgkbhPEEVF4ri87Y48FjSAxOcPmNp7He80fCfKD7JgrC9twIwkoXLu1QGOt1UiThGXnB7cxW23PUetH_yMvcamiSOxE-YPi2MiILWGfTr9MveQ6jO86AeDvsBFGb0Ta5P9qb1HiG1sV4lfSzUwv6H-BJdeHVYIVpHz-dVVsi4WY4Lw',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB49A1ML0Ok0tP0-bQom7LQzwuOMr4u9KFWaNcrE8lWjg3zYtFXQ26GpOgn-gfZKAc_RabLxZvOt2mnGNpHDhCG5x_9UekW9Y9mBCLUNggn3rjb3UJJs7KygRXQvtA_J24vdUKdXwI6gnRjPsYJgiJfIpXFct1SMn6i-2Lfec09dIp-6xLdV8jTeSqoLV6C9NcMA73Bt7_v0CaLZAUVACtIg0cgHmrA0_aO8Ne9Wirr0_QHSeQw1APrCw',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDqvlv_Q1vj1FDF9B1SH10P8obnajjqh4-xicqYNnfopI7q-PIHWTVT5pkPj3WEq1kocGVKD3_nKfbZjY-hShlkoefPpAF22lKGqBvgxMTVtGDT6tXc1jmwdqFwhl-e2tTXJAUdCU_CUKfyu6nvajd-bOjCe5SM3pjbwh8V4p9OIhhHiQCAMf0fdCdUaf2E16qGLnF8ASCP-j6wpNUyB8VeiYHwFnDCDZNLdw7ZEGHUArBhedqR4WiG7g',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAlfFPNSwtQNnj_tZ0XqC3HaLHCMBsfWek2hvKjBPL2IQOYeIYcU9oz94ubOXuyL7LA1slKTUgvQBMtPtb5DPqACfwsJnzDuGC6WPmKIywHE1Y41oWShx_TtzFALbslhuCB72xBGeP1ev0l0ysbHFLtE--HSY6AEg8WTNMhdh7CmyRgHYj32uLvAqnKhZnajCJbLMz4UqdNvUGoANqxtCg3ZSOpVbrWB_-HBjMVt_gOiqMtP9v6U-I3uA',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBr_cpvQTDpVyvAcHfJUaLwJ7iRJzucQth5zyU63zaMrT6bqp9vwjowYL9QC5JPICqLP31Ryams9nEcr-pHvi3hTS3wxM-T7dAm2eT99X6dujNwczSUUAvmoIoWPpAd65_d8aVXqw9V5ZqVhmF4jF3d1hFxr4Td5Dk_7SVO9dal15f97o1OGhtgObXZUp40CjWaqb6yOHQEx7x81gJawtn4vwmg2IAXuO2fb_d99SQy3alqR-4ij1NVNg',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBYqLS69lodFY-q-5bue5dIcGT2TTtsISNrTR4XU6hAK1vQJVEEgPKNPLmYbeLNvFagGx7DN17zLqJTb4hX46Kwo0laxTjAJIASgpjRggozgdZnKk3-T4tBG2Df3fKD6Kd7a9ibWG4T7-MIKLpltiRsuyGaRLl-UjFtOvA3fIOhgMo27NfQUqCjKZIDZaZTqwZfn0_s9qlserH-P7WgfZ5JLEVv72CBWSrz-LT4MCwt4-cwf3a_5i2KTQ',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC2Wf-DMyLU3-9qmMxKB5jlTGJ2qSUhVhpWBpf0fkIUqrWKqB03M-oRmxspBwsFWe_Ox6XuYG3jO7vDC1-l4V0NDghBNeHPSXy8pEVK8wbGKJEXpOse5wBrurSb4aX6pTfQRupM-U3Ssoa5DFsjW2XgITHBiqAEWVZOf7YRyq6cC3_KRM2tH7gxmWy6lztiOZ6ZPBYrmNX8Nu-gp7e8QTb4bkkDlKCGU1RrFpEjk9Dp7CCiM9TuI3iCHQ',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAyY6KCMCY5yTKXBYaYJebYkLsqwGKglyFSZZJSD2RQkB5cK9Cwjg8VWmTF2g6ocfO2tSs0WyfRJo3-ev_QIp51xMQOxG_JDbUN2cOH2bfw29V1MAdOTSe0PklgHnmf8MU1wX4sYCKo_OBRkAyS85agfWawQ0GIG79fUuD7yX0elBLUV2kwsgllVbF4h5l4YDCWWPFsEYNE7JDy9hr4gRuuwYil84vJ4H0dnbtEK45tA4GQ3krT9W7lSg',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XD-x0dfUjXw3MIH4Lhlyk6wMnHcQp-CBshOZ3azaTzmv0uS67O_9nIHwDGpP7lRmeFng2pWrK1mMwbMXMrGPi4PvSbqLIOCZnDBBbCRYzXuVkXH6NBAy19G-G1Cn3Wi-EAQUnaetj2Un35INsvDzibHUVTFn22q0uArSDNfmqjtFOijKJb2d3YQLmrCGC-FPdw7IQgqzgAVUPjnX8ISOjnzIW154VDqYeJmuKM9mzpg6272nT3s8-Q',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDfPZZBvk_nvpymjvlymjaX8o639vugOHBNFLexv54LTcTCk3kd_6iuzgcMgkcIo3VantYHBu8EItbvkOgYxoJeyC3DQyuCJPPyp1wEXYiF8u5aA5KkGM57fW-Pjayd0sltLaKhyXa1FgIFDDDfzE8uk2YzexO2eZiXLQ7ddEVjCJwzn6VRr7eROSX73DQETj-Hvzg3I9rN8HgojWroxJD1dpobfCo8jpQoLe4J0SOWpU-_Yi6x_G5qiQ',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDYq4h2lgrxJIUEMAoC2uufB-CBuWEEncgcLz6rY8IbnWIFba1UqWQSozpDJ6ssEQir-URYyxtVoQbNw4mdf_2FpgT7t5j7S-quf_r_tn4AoWc8Ey4880pnGnNds3P9U7VkULLxpAKOtwa2LBkcIJ7G4raeBX83K3b_0fsDI8YJXfSsihiM7Itglm9OwfQoyX-2SPfrQ4B26zK2ThXXzLgWKpLXmC8gGW3wlAlI7BEmClUY8YSQpitdgQ',
  ];

  // Community Notifications
  static List<NotificationItem> notifications = [
    NotificationItem(
      id: 'noti_1',
      user: MockData.biscuitPaw,
      type: NotificationType.like,
      message: 'liked your post: "Morning sunbeam nap is my cardio..."',
      timeAgo: '5m ago',
      postImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XD-x0dfUjXw3MIH4Lhlyk6wMnHcQp-CBshOZ3azaTzmv0uS67O_9nIHwDGpP7lRmeFng2pWrK1mMwbMXMrGPi4PvSbqLIOCZnDBBbCRYzXuVkXH6NBAy19G-G1Cn3Wi-EAQUnaetj2Un35INsvDzibHUVTFn22q0uArSDNfmqjtFOijKJb2d3YQLmrCGC-FPdw7IQgqzgAVUPjnX8ISOjnzIW154VDqYeJmuKM9mzpg6272nT3s8-Q',
      isRead: false,
    ),
    NotificationItem(
      id: 'noti_2',
      user: MockData.miloTheScottish,
      type: NotificationType.comment,
      message: 'commented: "The comfiest loaf ever! 😻"',
      timeAgo: '25m ago',
      postImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XD-x0dfUjXw3MIH4Lhlyk6wMnHcQp-CBshOZ3azaTzmv0uS67O_9nIHwDGpP7lRmeFng2pWrK1mMwbMXMrGPi4PvSbqLIOCZnDBBbCRYzXuVkXH6NBAy19G-G1Cn3Wi-EAQUnaetj2Un35INsvDzibHUVTFn22q0uArSDNfmqjtFOijKJb2d3YQLmrCGC-FPdw7IQgqzgAVUPjnX8ISOjnzIW154VDqYeJmuKM9mzpg6272nT3s8-Q',
      isRead: false,
    ),
    NotificationItem(
      id: 'noti_3',
      user: MockData.lunaCalico,
      type: NotificationType.treat,
      message: 'sent you a delicious Salmon Treat! 🐟✨',
      timeAgo: '1h ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'noti_4',
      user: MockData.oliverWhiskers,
      type: NotificationType.follow,
      message: 'started following you.',
      timeAgo: '3h ago',
      isRead: true,
      isFollowing: false,
    ),
    NotificationItem(
      id: 'noti_5',
      user: MockData.churuLover,
      type: NotificationType.mention,
      message: 'mentioned you in a caption: "@mochi_the_ragdoll cutest cat!"',
      timeAgo: '5h ago',
      postImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB49A1ML0Ok0tP0-bQom7LQzwuOMr4u9KFWaNcrE8lWjg3zYtFXQ26GpOgn-gfZKAc_RabLxZvOt2mnGNpHDhCG5x_9UekW9Y9mBCLUNggn3rjb3UJJs7KygRXQvtA_J24vdUKdXwI6gnRjPsYJgiJfIpXFct1SMn6i-2Lfec09dIp-6xLdV8jTeSqoLV6C9NcMA73Bt7_v0CaLZAUVACtIg0cgHmrA0_aO8Ne9Wirr0_QHSeQw1APrCw',
      isRead: true,
    ),
    NotificationItem(
      id: 'noti_6',
      user: MockData.biscuitPaw,
      type: NotificationType.like,
      message: 'liked your reel "Chasing butterflies ☀️"',
      timeAgo: '1d ago',
      postImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDqvlv_Q1vj1FDF9B1SH10P8obnajjqh4-xicqYNnfopI7q-PIHWTVT5pkPj3WEq1kocGVKD3_nKfbZjY-hShlkoefPpAF22lKGqBvgxMTVtGDT6tXc1jmwdqFwhl-e2tTXJAUdCU_CUKfyu6nvajd-bOjCe5SM3pjbwh8V4p9OIhhHiQCAMf0fdCdUaf2E16qGLnF8ASCP-j6wpNUyB8VeiYHwFnDCDZNLdw7ZEGHUArBhedqR4WiG7g',
      isRead: true,
    ),
    NotificationItem(
      id: 'noti_7',
      user: MockData.lunaCalico,
      type: NotificationType.like,
      message: 'liked your comment: "Purrfect vibes today 🐾"',
      timeAgo: '2d ago',
      isRead: true,
    ),
  ];
}

