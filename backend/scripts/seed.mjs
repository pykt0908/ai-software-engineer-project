import fs from 'fs';
import path from 'path';

const API_BASE = process.env.API_BASE || 'http://localhost:1337';

const MOCK_USERS = [
  {
    username: 'mochi_ragdoll',
    email: 'mochi@instacat.pet',
    password: 'password123',
    displayName: 'Mochi The Ragdoll',
    bio: 'Fluffy cloud living in Tokyo ☁️ Sunbeam connoisseur & treat enthusiast 🐾 Meow vibes only!',
    category: 'Ragdoll',
    website: 'mochi.instacat.pet',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDgHq4gqaix1Z8C7wnrG9dw8dQcSa6fwprjccleQOkLGHiHDm_S23rtMaEWSa93Wgjp2ubKkH2fMNZKfI_udBUhr2bUkoz5rb49FiL0FlMYlg_f_ECWWkJb4VYQKqgGmIYkn7mZr0eqo-es1dmY3QvgM7Xd4jiKHlMBmP1pH4bJTNFUkJh0lbGFXhUXK6KsZPKrCpMMFU9l0ZB65hPiJWdCMMStFnaTeUM7_sSSEQbTxXiqTOsFryu3mw',
  },
  {
    username: 'milo_scottish',
    email: 'milo@instacat.pet',
    password: 'password123',
    displayName: 'Milo Scottish Fold',
    bio: 'Folded ears, round cheeks & big eyes 🦉 Professional napper and bird watcher 🌿',
    category: 'Scottish Fold',
    website: 'milo.meow',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBKP0-y--DPd8PMpMEa-uUVkQU7UHOqOyRifF9Nmou5OG9q8FBA63lyB0VhH0W3JOGj3n6BURGOMmNWvdjeoDSZ1RxfnqQ730vb-LBcX1-S5cb9j0ejUXPSTgkbjxvuj7ZzquS9HsIjzd4XQNr2h-ws7jSSQELzF1vPZE6k2tmzasn4YhII-DMdXMG6aTxDoc3FBUn8LjmAxiORwdjFT0eVKujsMEHGqPZkHM1Y7sQgomINBtKydaHeHw',
  },
  {
    username: 'luna_calico',
    email: 'luna@instacat.pet',
    password: 'password123',
    displayName: 'Luna Queen of Boxes',
    bio: 'If it fits, I sits 📦 Calico beauty with attitude ✨ 3 AM hallway sprint champion 🏎️',
    category: 'Calico',
    website: 'luna.box',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAuM81muV4-auVviYV8d2mkDXrgf-2maGX995fexQdDsQY6s8DjE7NERzjWhOCNDlLdcSk4lZlep4igpnWLITMdxf1cTxWNJdUpVTZ9BO8cjRAqyQRnB2JFdzmwoBeTOtoGkrFmDAhtdIU_rvs6uzuEyWpCYeewLooyKYFJ7QZL2FdWLCxHPSJUpw9mf_8BJzyHzsSEbCZFRlIySz5sFU-WAdiodlHUdXT6vPBxSe_F3BE6m3ThmN1AQw',
  },
  {
    username: 'biscuit_tabby',
    email: 'biscuit@instacat.pet',
    password: 'password123',
    displayName: 'Biscuit The Tabby',
    bio: 'Making fresh biscuits 24/7 🍞 Purr motor running on premium salmon treats 🐟',
    category: 'Tabby',
    website: 'biscuit.paw',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBJt8VaXk4Zgd7GNmfMmhFi93IGwCCQunJPX2vl6Vp557bzBO6SytIxggzAeIuWejn11ioHu1g2bCYQ14GOXtwB5kNsAgngGZorc23oWdMM02l_A7uZzkTZa5yatmhwc-Ky4K1flsRIZUtuUYraoKs7LOclw9ii1On5wt4nqBFrRa-GtaeB90CZHDk4w7Vffixu6VL8RN8CT6Zkk0RroXauK3mjDPimS05Al_lN5uZgAvHzHXrmC9b3MQ',
  },
  {
    username: 'oliver_whiskers',
    email: 'oliver@instacat.pet',
    password: 'password123',
    displayName: 'Sir Oliver Whiskers',
    bio: 'British Shorthair royalty 👑 Distinguished gentleman in a tuxedo 🎩 Always majestic',
    category: 'British Shorthair',
    website: 'oliver.pet',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCNg0tHEFsrWsnyY89LdFF6ZstaK2tWj4YTcigVrGwKy8-ptnpkw393gGpwfdeH6oLmW5L4Np7eG69xY8puBmM7PhD8VIJV_5P_hGP8H0-fddKNiM9_t80xMUOCQa9EzEmw34w3jMI3Vu930XOU6dQA8N2ra3ii9N0lgwZQc-7I75yIMjigZyfW5itqOUmH9CXTirezA6upq77BUoUTqxRd1nutkMR2cjysYYSiIl-2BaxhUoeAL_fKrQ',
  },
  {
    username: 'churu_lover',
    email: 'churu@instacat.pet',
    password: 'password123',
    displayName: 'Kuro The Snack Bandit',
    bio: 'Will do acrobatics for Churu treats 😼 Master of funny cat memes & cardboard nibbling 😹',
    category: 'Funny Cats',
    website: 'kuro.treat',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuZC54QsSlf6TR5AmkVTxPPaPakSAEob28KF4Z9Sk6by3MWxmCCOnXvr5afvIyR5oc0fbD-xFwRZ4Y-12k0yMehigMxXe1yrmDiStMkYGuie6Pe9fl7_1XsyfUl5DcD-XercsiwBgTlLotyd0dc65qrmA5i4xc2D2VxshAkjsTm-Pq77eNnJbpJRWrVn5VZxhEffYe67RGjlw1XDe6Gbr9EiH_voz3HRMbdStl-tQhOAYdTi0keMBhZg',
  },
];

const CAT_IMAGE_URLS = [
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
  'https://lh3.googleusercontent.com/aida-public/AB6AXuDgHq4gqaix1Z8C7wnrG9dw8dQcSa6fwprjccleQOkLGHiHDm_S23rtMaEWSa93Wgjp2ubKkH2fMNZKfI_udBUhr2bUkoz5rb49FiL0FlMYlg_f_ECWWkJb4VYQKqgGmIYkn7mZr0eqo-es1dmY3QvgM7Xd4jiKHlMBmP1pH4bJTNFUkJh0lbGFXhUXK6KsZPKrCpMMFU9l0ZB65hPiJWdCMMStFnaTeUM7_sSSEQbTxXiqTOsFryu3mw',
];

const POST_TEMPLATES = [
  {
    authorUsername: 'mochi_ragdoll',
    caption: 'Sunbeam caught! The floor is warm and life is good ☀️🐾 #CatNaps #Ragdoll #Trending',
    location: 'Shibuya, Tokyo',
    imageIndices: [0],
  },
  {
    authorUsername: 'milo_scottish',
    caption: 'Found the ultimate cardboard box. It is my castle now 📦🏰 #FunnyCats #Trending',
    location: 'Edinburgh, UK',
    imageIndices: [1],
  },
  {
    authorUsername: 'luna_calico',
    caption: 'Late night window surveillance. The streetlights belong to me 🌙✨ #CatNaps #Reels',
    location: 'Bangkok, Thailand',
    imageIndices: [2],
  },
  {
    authorUsername: 'biscuit_tabby',
    caption: 'Fresh sourdough biscuits in production! Extra purrs added at no charge 🍞❤️ #Kittens #Trending',
    location: 'Melbourne, Australia',
    imageIndices: [3, 4],
  },
  {
    authorUsername: 'oliver_whiskers',
    caption: 'Distinguished gentleman waiting patiently for afternoon tea and fish treats 🐟☕ #Snacks & Treats #Trending',
    location: 'London, UK',
    imageIndices: [5],
  },
  {
    authorUsername: 'churu_lover',
    caption: 'Caught mid-zoomie! 3 AM is the ideal time to sprint across the living room 🚀😹 #FunnyCats #Reels',
    location: 'Osaka, Japan',
    imageIndices: [6],
  },
  {
    authorUsername: 'mochi_ragdoll',
    caption: 'Living cloud mode activated. Do not disturb unless you bring salmon paste ☁️🍣 #Ragdoll #CatNaps',
    location: 'Tokyo, Japan',
    imageIndices: [7],
  },
  {
    authorUsername: 'milo_scottish',
    caption: 'Wait, did someone whisper the word "treat"? My ears are ready! 🦉👂 #Snacks & Treats #Kittens',
    location: 'Edinburgh, UK',
    imageIndices: [8],
  },
  {
    authorUsername: 'luna_calico',
    caption: 'Stealing mom’s favorite gaming chair while she grabbed coffee. Checkmate 😼🎮 #FunnyCats #Trending',
    location: 'Bangkok, Thailand',
    imageIndices: [9],
  },
  {
    authorUsername: 'biscuit_tabby',
    caption: 'Sunday nap marathon in full swing. Goal: 18 hours of continuous slumber 😴💤 #CatNaps #Trending',
    location: 'Sydney, Australia',
    imageIndices: [10],
  },
  {
    authorUsername: 'oliver_whiskers',
    caption: 'A proper portrait for the royal whiskers gallery 👑🐾 #Trending #British Shorthair',
    location: 'London, UK',
    imageIndices: [11],
  },
  {
    authorUsername: 'churu_lover',
    caption: 'Churu treat radar locked on target! 🎯 Best part of the day without question 🐟❤️ #Snacks & Treats #Reels',
    location: 'Kyoto, Japan',
    imageIndices: [0, 1],
  },
];

const SAMPLE_COMMENTS = [
  'Meow meow so adorable! That fluffy fur 😍🐾',
  'Give this cute kitty all the treats immediately! 🐟✨',
  'Such a beautiful angle! What a photogenic cat 😻',
  'Haha that face is hilarious! Made my whole morning 😹',
  'Purrfect biscuit making technique! 100/10 🍞❤️',
  'Cozy vibes! I want to nap right next to you 💤☁️',
  'Those eyes are absolutely mesmerizing! 🧡👀',
  'Peak cat behavior right there 📦👑',
];

async function fetchWithRetry(url, options, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(url, options);
      return res;
    } catch (err) {
      if (i === retries - 1) throw err;
      await new Promise((r) => setTimeout(r, 1000));
    }
  }
}

export async function seedMockCats() {
  console.log('🐾 Starting Mock Cat Data Seeding...');

  // 1. Authenticate or register users
  const userMap = {}; // username -> { jwt, user, documentId, id }

  for (const u of MOCK_USERS) {
    let token = null;
    let userData = null;

    // Try logging in
    const loginRes = await fetch(`${API_BASE}/api/auth/local`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ identifier: u.username, password: u.password }),
    });

    if (loginRes.ok) {
      const json = await loginRes.json();
      token = json.jwt;
      userData = json.user;
    } else {
      // Register if not exists
      const regRes = await fetch(`${API_BASE}/api/auth/local/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: u.username,
          email: u.email,
          password: u.password,
        }),
      });

      if (regRes.ok) {
        const json = await regRes.json();
        token = json.jwt;
        userData = json.user;
      } else {
        console.error(`Failed to register/login user ${u.username}:`, await regRes.text());
        continue;
      }
    }

    // Update profile
    await fetch(`${API_BASE}/api/me`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        displayName: u.displayName,
        bio: u.bio,
        category: u.category,
        website: u.website,
        isPublic: true,
      }),
    });

    userMap[u.username] = {
      jwt: token,
      user: userData,
      id: userData.id,
      documentId: userData.documentId,
    };
    console.log(`✅ User ready: @${u.username} (${u.displayName})`);
  }

  const registeredUsernames = Object.keys(userMap);
  if (registeredUsernames.length === 0) {
    throw new Error('No mock users available for seeding.');
  }

  // 2. Upload cat images to Strapi media library
  const anyToken = userMap[registeredUsernames[0]].jwt;
  const uploadedImageIds = [];

  console.log(`📸 Uploading ${CAT_IMAGE_URLS.length} mock cat images...`);
  for (let i = 0; i < CAT_IMAGE_URLS.length; i++) {
    try {
      const imgRes = await fetchWithRetry(CAT_IMAGE_URLS[i]);
      if (!imgRes.ok) {
        console.warn(`Could not download image ${i}: HTTP ${imgRes.status}`);
        continue;
      }
      const buffer = await imgRes.arrayBuffer();

      const formData = new FormData();
      const blob = new Blob([buffer], { type: 'image/jpeg' });
      formData.append('files', blob, `mock_cat_${i + 1}.jpg`);

      const uploadRes = await fetch(`${API_BASE}/api/upload`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${anyToken}`,
        },
        body: formData,
      });

      if (uploadRes.ok) {
        const result = await uploadRes.json();
        if (Array.isArray(result) && result[0]?.id) {
          uploadedImageIds.push(result[0].id);
          console.log(`Uploaded image [${i + 1}/${CAT_IMAGE_URLS.length}]: ID ${result[0].id}`);
        }
      } else {
        console.warn(`Upload failed for image ${i}:`, await uploadRes.text());
      }
    } catch (err) {
      console.warn(`Error uploading cat image ${i}:`, err.message);
    }
  }

  if (uploadedImageIds.length === 0) {
    throw new Error('No images could be uploaded.');
  }

  // Update user avatars with some of the uploaded images
  for (let i = 0; i < registeredUsernames.length; i++) {
    const uname = registeredUsernames[i];
    const u = userMap[uname];
    const avatarId = uploadedImageIds[i % uploadedImageIds.length];
    try {
      await fetch(`${API_BASE}/api/me`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${u.jwt}`,
        },
        body: JSON.stringify({ avatar: avatarId }),
      });
    } catch (e) {}
  }

  // 3. Create Posts
  console.log('📝 Creating posts for mock users...');
  const createdPosts = [];

  for (let i = 0; i < POST_TEMPLATES.length; i++) {
    const template = POST_TEMPLATES[i];
    const author = userMap[template.authorUsername] || userMap[registeredUsernames[0]];

    const imageIds = template.imageIndices
      .map((idx) => uploadedImageIds[idx % uploadedImageIds.length])
      .filter(Boolean);

    if (imageIds.length === 0) {
      imageIds.push(uploadedImageIds[0]);
    }

    try {
      const postRes = await fetch(`${API_BASE}/api/posts`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${author.jwt}`,
        },
        body: JSON.stringify({
          caption: template.caption,
          images: imageIds,
          location: template.location,
        }),
      });

      if (postRes.ok) {
        const json = await postRes.json();
        const postData = json.data || json;
        createdPosts.push(postData);
        console.log(`Created post [${i + 1}/${POST_TEMPLATES.length}]: "${template.caption.slice(0, 35)}..."`);
      } else {
        console.warn(`Post creation failed:`, await postRes.text());
      }
    } catch (err) {
      console.warn(`Error creating post:`, err.message);
    }
  }

  console.log(`✅ Total posts created: ${createdPosts.length}`);

  // 4. Create Follow relationships
  console.log('🤝 Creating follow relationships...');
  for (let i = 0; i < registeredUsernames.length; i++) {
    const follower = userMap[registeredUsernames[i]];
    // Follow 2-3 other users
    for (let j = 0; j < registeredUsernames.length; j++) {
      if (i !== j && (i + j) % 2 === 0) {
        const target = userMap[registeredUsernames[j]];
        try {
          await fetch(`${API_BASE}/api/users/${target.documentId}/follow`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${follower.jwt}`,
            },
          });
        } catch (e) {}
      }
    }
  }

  // 5. Create Likes on Posts
  console.log('❤️ Creating likes on posts...');
  for (let pIdx = 0; pIdx < createdPosts.length; pIdx++) {
    const post = createdPosts[pIdx];
    const docId = post.documentId;
    if (!docId) continue;

    // Like by 2 to 5 random users
    for (let uIdx = 0; uIdx < registeredUsernames.length; uIdx++) {
      if ((pIdx + uIdx) % 2 === 0 || (pIdx + uIdx) % 3 === 0) {
        const likingUser = userMap[registeredUsernames[uIdx]];
        try {
          await fetch(`${API_BASE}/api/posts/${docId}/like`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${likingUser.jwt}`,
            },
          });
        } catch (e) {}
      }
    }
  }

  // 6. Create Comments on Posts
  console.log('💬 Creating comments on posts...');
  for (let pIdx = 0; pIdx < createdPosts.length; pIdx++) {
    const post = createdPosts[pIdx];
    const docId = post.documentId;
    if (!docId) continue;

    // Add 1 to 3 comments
    const numComments = 1 + (pIdx % 3);
    for (let c = 0; c < numComments; c++) {
      const commenterName = registeredUsernames[(pIdx + c + 1) % registeredUsernames.length];
      const commenter = userMap[commenterName];
      const commentText = SAMPLE_COMMENTS[(pIdx + c) % SAMPLE_COMMENTS.length];

      try {
        await fetch(`${API_BASE}/api/posts/${docId}/comments`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${commenter.jwt}`,
          },
          body: JSON.stringify({ text: commentText }),
        });
      } catch (e) {}
    }
  }

  console.log('🎉 Mock cat seeding completed successfully!');
  return {
    usersCreated: registeredUsernames.length,
    postsCreated: createdPosts.length,
    imagesUploaded: uploadedImageIds.length,
  };
}

if (process.argv[1] && process.argv[1].endsWith('seed.mjs')) {
  seedMockCats()
    .then((res) => {
      console.log('Result:', res);
      process.exit(0);
    })
    .catch((err) => {
      console.error('Seeding error:', err);
      process.exit(1);
    });
}
