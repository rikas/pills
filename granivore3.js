const BOTTLE_WIDTH = 8;
const BOTTLE_HEIGHT = 16;
const CELL_SIZE = 16;

const ITEM_COLORS = {
  YELLOW: 0,
  RED: 1,
  BLUE: 2,
};

const VIRUS_COLOR_TABLE = [
  ITEM_COLORS.YELLOW,
  ITEM_COLORS.RED,
  ITEM_COLORS.BLUE,
  ITEM_COLORS.BLUE,
  ITEM_COLORS.RED,
  ITEM_COLORS.YELLOW,
  ITEM_COLORS.YELLOW,
  ITEM_COLORS.RED,
  ITEM_COLORS.BLUE,
  ITEM_COLORS.BLUE,
  ITEM_COLORS.RED,
  ITEM_COLORS.YELLOW,
  ITEM_COLORS.YELLOW,
  ITEM_COLORS.RED,
  ITEM_COLORS.BLUE,
  ITEM_COLORS.RED,
];

const VIRUS_COLOR_BIT_MASKS = {
  [ITEM_COLORS.YELLOW]: 1,
  [ITEM_COLORS.RED]: 2,
  [ITEM_COLORS.BLUE]: 4,
};

// Arrays of seeds/bottle configurations, keyed by the max level of the max height of the level
const generatedSeeds = {};

function getGeneratedSeeds(level) {
  const maxLevelOfMaxRow = level;
  if (!generatedSeeds[maxLevelOfMaxRow]) {
    generatedSeeds[maxLevelOfMaxRow] = [];
    for (let i = 0; i < 256; i++) {
      for (let j = 0; j < 256; j += 2) {
        if (i === 0 && j <= 1) {
          continue;
        }
        const seed = [i, j];
        generatedSeeds[maxLevelOfMaxRow].push(
          generateOutput(seed, maxLevelOfMaxRow),
        );
      }
    }
  }
  return generatedSeeds[maxLevelOfMaxRow];
}

function showToast(message) {
  const toastEl = document.getElementById("Toast");
  toastEl.textContent = message;
  toastEl.classList.remove("Hidden");
}

function hideToast() {
  const toastEl = document.getElementById("Toast");
  toastEl.classList.add("Hidden");
}

function generateOutput(seed, level) {
  const originalSeed = seed.slice();
  const capsules = [];
  seed = generateCapsules(capsules, seed);
  const viruses = [];
  seed = generateViruses(viruses, seed, level);
  return { seed: originalSeed, nextSeed: seed.slice(), capsules, viruses };
}

function generateCapsules(capsules, seed) {
  let capsulesRemaining = 128;
  let lastCapsule = 0;
  while (capsulesRemaining > 0) {
    seed = rotateBytes(seed);
    const capsule = ((seed[0] % 16) + lastCapsule) % 9;
    lastCapsule = capsule;
    capsules[--capsulesRemaining] = capsule;
  }
  return seed;
}

function generateViruses(viruses, seed, level = 20) {
  const cappedLevel = Math.min(20, level);
  let virusesRemaining = (cappedLevel + 1) * 4;
  const maxRow = getMaxRow(cappedLevel);
  outerLoop: while (virusesRemaining > 0) {
    let row;
    do {
      seed = rotateBytes(seed);
    } while ((row = seed[0] % BOTTLE_HEIGHT) > maxRow);
    const y = BOTTLE_HEIGHT - 1 - row;
    const x = seed[1] % BOTTLE_WIDTH;
    let position = y * BOTTLE_WIDTH + x;
    let color = virusesRemaining % 4;
    if (color === 3) {
      seed = rotateBytes(seed);
      color = VIRUS_COLOR_TABLE[seed[1] % 16];
    }
    adjustment: while (true) {
      while (true) {
        if (viruses[position] === undefined) {
          break;
        }
        if (++position >= BOTTLE_WIDTH * BOTTLE_HEIGHT) {
          continue outerLoop;
        }
      }
      let surroundingViruses = 0;
      surroundingViruses |=
        VIRUS_COLOR_BIT_MASKS[
          viruses[position - 16] === undefined
            ? undefined
            : viruses[position - 16]
        ];
      surroundingViruses |=
        VIRUS_COLOR_BIT_MASKS[
          viruses[position + 16] === undefined
            ? undefined
            : viruses[position + 16]
        ];
      if (position % BOTTLE_WIDTH >= 2) {
        surroundingViruses |=
          VIRUS_COLOR_BIT_MASKS[
            viruses[position - 2] === undefined
              ? undefined
              : viruses[position - 2]
          ];
      }
      if (position % BOTTLE_WIDTH < 6) {
        surroundingViruses |=
          VIRUS_COLOR_BIT_MASKS[
            viruses[position + 2] === undefined
              ? undefined
              : viruses[position + 2]
          ];
      }
      while (true) {
        if (surroundingViruses === 7) {
          position++;
          continue adjustment;
        }
        if ((surroundingViruses & VIRUS_COLOR_BIT_MASKS[color]) === 0) {
          break;
        }
        if (color === ITEM_COLORS.YELLOW) {
          color = ITEM_COLORS.BLUE;
        } else if (color === ITEM_COLORS.RED) {
          color = ITEM_COLORS.YELLOW;
        } else if (color === ITEM_COLORS.BLUE) {
          color = ITEM_COLORS.RED;
        }
      }
      viruses[position] = color;
      virusesRemaining--;
      break;
    }
  }
  return seed;
}

function getMaxRow(level) {
  return 9 + Math.max(0, Math.floor((level - 13) / 2));
}

function getMaxLevelOfMaxRow(level) {
  if (level >= 19) {
    return 20;
  } else if (level >= 17) {
    return 18;
  } else if (level >= 15) {
    return 16;
  } else {
    return 14;
  }
}

function rotateBytes(seed) {
  let carry0 = 0;
  let carry1 = 0;
  if (((seed[0] & 2) ^ (seed[1] & 2)) != 0) {
    carry0 = 1;
    carry1 = 1;
  }
  for (let x = 0; x < 2; x++) {
    carry0 = seed[x] & 1;
    seed[x] = (carry1 << 7) | (seed[x] >> 1);
    carry1 = carry0;
  }
  return seed;
}

let selectedLevel = 20;
let selectedSeed = "";
let selectedColor = ITEM_COLORS.YELLOW;
let searchBottle = {};
let numToRender = 10;

function clickedOnPosition(position) {
  if (
    searchBottle[position] !== undefined &&
    searchBottle[position] === selectedColor
  ) {
    removeFromSearch(position);
  } else {
    addToSearch(position);
  }
  updateSeeds();
}

function addToSearch(position) {
  searchBottle[position] = selectedColor;
  const cell = getCell(position);
  removeColorClasses(cell);
  addSelectedColorClass(cell);
  removeHoverClasses(cell);
  addSelectedHoverClass(cell, position);
}

function removeFromSearch(position) {
  delete searchBottle[position];
  const cell = getCell(position);
  removeColorClasses(cell);
}

function removeColorClasses(cell) {
  Object.values(ITEM_COLORS).forEach((color) => {
    cell.classList.remove(`Color${color}`);
  });
}

function addSelectedColorClass(cell) {
  cell.classList.add(`Color${selectedColor}`);
}

function getCell(position) {
  return document.getElementById(`Cell${position}`);
}

function updateSeeds() {
  const startPosition =
    (BOTTLE_HEIGHT - getMaxRow(selectedLevel) - 1) * BOTTLE_WIDTH;
  const cappedSearchBottle = Object.keys(searchBottle).reduce(
    (map, position) => {
      if (position >= startPosition) {
        map[position] = searchBottle[position];
      }
      return map;
    },
    {},
  );
  const isSeedSelectedAndValid =
    selectedSeed != "" && isValidSeed(selectedSeed);
  const seeds = getGeneratedSeeds(selectedLevel).filter((seed) => {
    if (isSeedSelectedAndValid) {
      return formatSeed(seed.seed) === selectedSeed;
    }
    const positions = Object.keys(cappedSearchBottle);
    for (let i = 0; i < positions.length; i++) {
      const position = positions[i];
      if (seed.viruses[position] !== cappedSearchBottle[position]) {
        return false;
      }
    }
    return true;
  });
  renderSeeds(seeds);
}

function renderSeeds(seeds) {
  const renderedSeeds = document.getElementById("RenderedSeeds");
  while (renderedSeeds.firstChild) {
    renderedSeeds.firstChild.remove();
  }
  const numFoundEl = document.getElementById("NumFound");
  numFoundEl.textContent = seeds.length;
  for (let i = 0; i < Math.min(seeds.length, numToRender); i++) {
    const seedContainer = document.createElement("div");
    seedContainer.className = "SeedContainer";
    const bottle = document.createElement("div");
    bottle.className = "Bottle";
    for (let row = 0; row < BOTTLE_HEIGHT; row++) {
      for (let column = 0; column < BOTTLE_WIDTH; column++) {
        const position = row * BOTTLE_WIDTH + column;
        const cell = document.createElement("div");
        cell.className = `Cell${seeds[i].viruses[position] !== undefined ? " Color" + seeds[i].viruses[position] : ""}`;
        cell.style = `top: ${row * CELL_SIZE}px; left: ${column * CELL_SIZE}px`;
        bottle.appendChild(cell);
      }
    }
    const capsules = document.createElement("div");
    capsules.className = "Capsules";
    for (let j = 1; j <= 128; j++) {
      const capsule = seeds[i].capsules[j % 128];
      const capsuleEl = document.createElement("div");
      capsuleEl.className = "Capsule";
      const leftHalfColor = getLeftHalfColor(capsule);
      const rightHalfColor = getRightHalfColor(capsule);
      const leftHalfCapsuleEl = document.createElement("div");
      const rightHalfCapsuleEl = document.createElement("div");
      leftHalfCapsuleEl.className = `Color${leftHalfColor}`;
      rightHalfCapsuleEl.className = `Color${rightHalfColor}`;
      capsuleEl.appendChild(leftHalfCapsuleEl);
      capsuleEl.appendChild(rightHalfCapsuleEl);
      capsules.appendChild(capsuleEl);
    }
    const bottleAndCapsulesContainer = document.createElement("div");
    bottleAndCapsulesContainer.className = "BottleAndCapsulesContainer";
    bottleAndCapsulesContainer.appendChild(bottle);
    bottleAndCapsulesContainer.appendChild(capsules);
    seedContainer.appendChild(bottleAndCapsulesContainer);

    const seedEl = document.createElement("div");
    seedEl.className = "Seed";
    const seed = formatSeed(seeds[i].seed);
    const nextSeed = formatSeed(seeds[i].nextSeed);
    seedEl.innerHTML =
      `Seed: <b>${seed}</b><br>` +
      `Next seed: <b><a href="#" onClick="goTo(event, '${selectedLevel}', '${nextSeed}')">${nextSeed}</a> <a href="#" onClick="goTo(event, '${Math.min(selectedLevel + 1, 20)}', '${nextSeed}')">+1 level</a></b>`;
    seedContainer.appendChild(seedEl);

    const virusCountStats = document.createElement("div");
    virusCountStats.className = "Stats";
    const virusCountDescriptionEl = document.createElement("div");
    virusCountDescriptionEl.textContent = "# viruses:";
    virusCountStats.appendChild(virusCountDescriptionEl);
    Object.values(ITEM_COLORS).forEach((color) => {
      const virusColorEl = document.createElement("div");
      virusColorEl.className = `Stat Color${color}`;
      virusColorEl.innerText = getVirusColorCount(seeds[i], color);
      virusCountStats.appendChild(virusColorEl);
    });
    seedContainer.appendChild(virusCountStats);

    const capsuleCountStats = document.createElement("div");
    capsuleCountStats.className = "Stats";
    const capsuleCountDescriptionEl = document.createElement("div");
    capsuleCountDescriptionEl.textContent = "# capsules:";
    capsuleCountStats.appendChild(capsuleCountDescriptionEl);
    Object.values(ITEM_COLORS).forEach((color) => {
      const capsuleColorEl = document.createElement("div");
      capsuleColorEl.className = `Stat Color${color}`;
      capsuleColorEl.innerText = getCapsuleColorCount(seeds[i], color);
      capsuleCountStats.appendChild(capsuleColorEl);
    });
    seedContainer.appendChild(capsuleCountStats);

    renderedSeeds.appendChild(seedContainer);
  }
}

function getLeftHalfColor(capsule) {
  return Math.floor(capsule / 3);
}

function getRightHalfColor(capsule) {
  return capsule % 3;
}

function getVirusColorCount(seed, color) {
  return seed.viruses.filter((virusColor) => virusColor === color).length;
}

function getCapsuleColorCount(seed, color) {
  return seed.capsules.reduce((sum, capsule) => {
    return (
      sum +
      (getLeftHalfColor(capsule) === color ? 1 : 0) +
      (getRightHalfColor(capsule) === color ? 1 : 0)
    );
  }, 0);
}

function formatSeed(seed) {
  return seed
    .map((val) => val.toString(16).padStart(2, "0"))
    .join("")
    .toUpperCase();
}

function updateSelectedColor(color) {
  selectedColor = color;
  for (let row = 3; row < BOTTLE_HEIGHT; row++) {
    for (let column = 0; column < BOTTLE_WIDTH; column++) {
      const position = row * BOTTLE_WIDTH + column;
      const cell = getCell(position);
      removeHoverClasses(cell);
      addSelectedHoverClass(cell, position);
    }
  }
}

function updateSelectedLevel(level) {
  selectedLevel = parseInt(level, 10);
  const maxRow = getMaxRow(level);
  const startingPosition = (BOTTLE_HEIGHT - 1 - maxRow) * BOTTLE_WIDTH;
  for (
    let position = BOTTLE_WIDTH * 3;
    position < BOTTLE_WIDTH * 7;
    position++
  ) {
    const cell = getCell(position);
    toggleCell(cell, /* isVisible */ position >= startingPosition);
  }
  updateSeeds();
}

function updateSelectedSeed(seed) {
  if (isValidSeed(seed.toUpperCase())) {
    setSelectedSeedValid();
  } else {
    setSelectedSeedInvalid();
    return;
  }
  const parsedSeed = parseInt(seed, 16);
  const adjustedSeed =
    parsedSeed % 2 === 0
      ? seed
      : (parsedSeed - 1).toString(16).padStart(4, "0");
  selectedSeed = adjustedSeed.toUpperCase();
  updateSeeds();
}

function goTo(event, level, seed) {
  event.preventDefault();
  const selectedLevelEl = document.getElementById("Level");
  selectedLevelEl.value = level;
  selectedLevelEl.dispatchEvent(new Event("input"));
  const selectedSeedEl = document.getElementById("Seed");
  selectedSeedEl.value = seed;
  selectedSeedEl.dispatchEvent(new Event("input"));
}

function setSelectedSeedValidity(isValid) {
  const selectedSeedEl = document.getElementById("Seed");
  const invalidClass = "Invalid";
  if (isValid) {
    selectedSeedEl.classList.remove(invalidClass);
  } else {
    selectedSeedEl.classList.add(invalidClass);
  }
}

function setSelectedSeedInvalid() {
  setSelectedSeedValidity(false /* isValid */);
}

function setSelectedSeedValid() {
  setSelectedSeedValidity(true /* isValid */);
}

function isValidSeed(seed) {
  return seed.match(/[A-F0-9]{4}/) && seed != "0000" && seed !== "0001";
}

function updateNumToRender(num) {
  numToRender = num;
  updateSeeds();
}

function toggleCell(cell, isVisible) {
  if (isVisible) {
    cell.classList.remove("Hidden");
  } else {
    cell.classList.add("Hidden");
  }
}

function removeHoverClasses(cell) {
  Object.values(ITEM_COLORS).forEach((color) => {
    cell.classList.remove(`Color${color}Hover`);
  });
  cell.classList.remove("CellHover");
}

function addSelectedHoverClass(cell, position) {
  cell.classList.add(
    searchBottle[position] === selectedColor
      ? "CellHover"
      : `Color${selectedColor}Hover`,
  );
}

function reset() {
  searchBottle = {};
  for (let row = 3; row < BOTTLE_HEIGHT; row++) {
    for (let column = 0; column < BOTTLE_WIDTH; column++) {
      const position = row * BOTTLE_WIDTH + column;
      const cell = getCell(position);
      removeColorClasses(cell);
      removeHoverClasses(cell);
      addSelectedHoverClass(cell, position);
    }
  }
  updateSeeds();
}

window.addEventListener("DOMContentLoaded", () => {
  const bottle = document.getElementById("SearchBottle");
  for (let row = 3; row < BOTTLE_HEIGHT; row++) {
    for (let column = 0; column < BOTTLE_WIDTH; column++) {
      const position = row * BOTTLE_WIDTH + column;
      const cell = document.createElement("div");
      cell.id = `Cell${position}`;
      cell.className = "Cell";
      cell.addEventListener("click", () => clickedOnPosition(position));
      cell.style = `top: ${row * CELL_SIZE}px; left: ${column * CELL_SIZE}px`;
      bottle.appendChild(cell);
    }
  }
  document
    .getElementById("Level")
    .addEventListener("input", (e) => updateSelectedLevel(e.target.value));
  document
    .getElementById("Seed")
    .addEventListener("input", (e) => updateSelectedSeed(e.target.value));
  const palette = document.getElementById("Palette");
  Object.keys(ITEM_COLORS).forEach((color) => {
    const button = document.createElement("button");
    button.className = `Button Color${ITEM_COLORS[color]}`;
    button.innerText = color;
    button.addEventListener("click", () =>
      updateSelectedColor(ITEM_COLORS[color]),
    );
    palette.appendChild(button);
  });
  document.getElementById("Reset").addEventListener("click", () => {
    reset();
  });
  updateSelectedColor(ITEM_COLORS.YELLOW);
  document
    .getElementById("NumToRender")
    .addEventListener("input", (e) => updateNumToRender(e.target.value));
});
